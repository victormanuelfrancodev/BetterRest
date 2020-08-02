//
//  ContentView.swift
//  BetterRest
//
//  Created by Victor Manuel Lagunas Franco on 10/11/19.
//  Copyright © 2019 Victor Manuel Lagunas Franco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
       
        NavigationView{
            Form{
                Section{
                    Text("When do you want to wake up?")
                                       .font(.headline)
                                   DatePicker("Please enter a time",selection: $wakeUp,
                                              displayedComponents: .hourAndMinute)
                                       .labelsHidden()
                                       .datePickerStyle(WheelDatePickerStyle())
                }
                Section{
                    Text("Desired amount of sleep")
                                               .font(.headline)
                                       Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                                           Text("\(sleepAmount,specifier: "%g") hours")
                                       }
                }
            
                Section{
                    Text("Daily coffe intake")
                                           .font(.headline)
                    Picker("Daily coffe intake", selection: $coffeAmount) {
                        ForEach(1..<21){
                            Text("\($0) cups")
                        }
                    }
                    
                }
            }.navigationBarTitle("BetteerRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedTime){
                    Text("Calculate")
                }
            ).alert(isPresented: $showingAlert){
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }

    static var defaultWakeTime:Date{
        var components = DateComponents()
            components.hour = 7
            components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedTime(){
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertMessage
                = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bed time is..."
        } catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calcuating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
