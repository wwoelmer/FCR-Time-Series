#####################################################################################################################################################
######################## Script to calculate light extinction coefficient ################################################################3


library(tidyverse)
#setwd("C:/Users/wwoel/Dropbox/FCR_TimeSeries")


#read in YSI data
light <- read.csv("./YSI_PAR_SECCHI/YSI_PAR_profiles.csv")

#subset YSI data to only PAR
light <- light %>% select(DateTime, Depth_m, PAR_umolm2s)
light$DateTime <- as.Date(light$DateTime, "%Y-%m-%d")
colnames(light) <- c("Date","Depth","PAR")


#Limit to only observations with data (in case data is not entered for some days/depths)
library(stats)
light <- na.omit(light)

#get rid of zeroes (because you can't take log of 0)
light <- light[!light$PAR==0,]



#For-loop to plot PAR values by day
#Just to make sure everything looks relatively normal
dates <- unique(light$Date)
d <- c(0:5)
par(mfrow=c(2,2))

for (i in 1:length(dates)){
  j=dates[i]
  q <- subset(light, light$Date == j)
  plot(q$PAR,q$Depth,
       main = j,
       xlab = "Light",
       ylab = "Depth")
  } 

#For-loop to plot ln of PAR
#Again, just to lay eyes on it

for (i in 1:length(dates)){
  j=dates[i]
  q <- subset(light, light$Date == j)
  plot(log(q$PAR),q$Depth,
       ylim = rev(range(d)),
       main = j,
       xlab = "Light",
       ylab = "Depth",
       abline(lm(q$Depth ~ log(q$PAR))))
  
  
} 


#Get slope for Kd
final <- matrix(data=NA, ncol=2, nrow=length(dates))


for (i in 1:length(dates)){
  j=dates[i]
  q <- subset(light, light$Date == j)
  mod <- lm(q$Depth ~ log(q$PAR))
  slope <- mod$coefficients[2]
  temp <- c(j,slope)
  final[i,] <- temp
  
}

final <- data.frame(final)
final$Date <- dates
final <- final %>% select(-X1)
colnames(final)[1] <- "Kd"
colnames(final)[2] <- "Date"
final <- final[, c("Date", "Kd")]

#Yay! :)
write.csv(final, "FCR_Kd.csv")

