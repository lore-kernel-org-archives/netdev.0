From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Strange TCP SACK behaviour in Linux TCP
Date: Wed, 19 Jul 2006 09:30:37 +0200
Message-ID: <44BDDF9D.2000002@kom.aau.dk>
References: <44BD0A5F.4090001@kom.aau.dk> <20060718155706.777ea1f3@localhost.localdomain> <44BD5B16.8080303@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:55033 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S932516AbWGSHaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 03:30:39 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
In-Reply-To: <44BD5B16.8080303@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Could you please CC your answers to me? thanx!

Oumer Teyeb wrote:

> Hi Stephen,
>
> Thanks for the quick response.
>
> I have done what you asked and you can find the files at
> www.kom.auc.dk/~oumer/sackstuff.tar.gz
> I have run the different cases 10 times each,
>
> NT_NSACK[1-10].dat---no timestamp, no SACK
> NT_SACK[1-10].dat----no timestamp, SACK
> T_NSACK[1-10].dat---timestamp, no SACK
> T_SACK[1-10].dat----timestamp. SACK
>
> the files without extension are just two column files that summarize 
> the ten runs for the four different cases, the first column in the # 
> retransmission, and second column is the download time, the values are 
> gathered from tcptrace
>
> the two eps files are just the plot summarizing  the above average 
> download time and average retransmission # for each case...
>
> one more thing in the trace files, you will find 3 tcp connections, 
> the first one is not modified by my emulator that causes the 
> reordering (actually, that is the connection through which I reset the 
> destination catch that stores some metrics from previous runs using 
> some commands via ssh), the second one is the ftp control channel and 
> the third one is the ftp data channel....the emulator affects the last 
> two channels
> and causes reordering once in a while.....
> please dont hesistate to ask me if anything is not clear...
>
> Thanks a lot for taking the time
>
> Regards,
> Oumer
>
> Stephen Hemminger wrote:
>
>> On Tue, 18 Jul 2006 18:20:47 +0200
>> Oumer Teyeb <oumer@kom.aau.dk> wrote:
>>
>>  
>>
>>> Hello Guys,
>>>
>>> I have some questions regarding TCP SACK implementation in Linux .
>>> As I am a subscriber, could you please cc the reply to me? thanks!
>>>
>>>
>>> I am doing these experiments to find out the impact of reordering. 
>>> So I have different TCP versions (newReno, SACK, FACk, DSACK, 
>>> FRTO,....) as implemented in Linux. and I am trying their 
>>> combination to see how they behave. What struck me was that when I 
>>> dont use timestamps, introducing SACK increases the download time 
>>> but decreases the total number of retransmissions.
>>> When timestamps is used, SACK leads to an increase in both the 
>>> download time and the retransmissions.
>>>
>>> So I looked further into the results, and what I found was that when 
>>> SACK  is used, the retransmissions seem to happen earlier .
>>> at www.kom.auc.dk/~oumer/first_transmission_times.pdf
>>> you can find the pic of cdf of the time when the first TCP 
>>> retransmission occured for the four combinations of SACK and 
>>> timestamps after hundrends of downloads of a 100K file for the 
>>> different conditions under network reordering...
>>>
>>> This explains the reason why the download time increases with SACK, 
>>> because the earlier we go into fast recovery the longer the time we 
>>> spend on congestion avoidance, and the longer the download time....
>>>
>>> ...but I couldnt figure out why the retransmissions occur earlier 
>>> for SACK than no SACK TCP. As far as I know, for both SACK and non 
>>> SACK cases, we need three (or more according to the setting) 
>>> duplicate ACKs to enter the fast retransmission /recovery state.... 
>>> which would have resulted in the same behaviour to the first 
>>> occurance of a retransmission..... or is there some undocumented 
>>> enhancment in Linux TCP when using SACK that makes it enter fast 
>>> retransmit earlier... the ony explanation I could imagine is 
>>> something like this
>>>
>>> non SACK case
>>> =============
>>> 1 2 3 4 5 6 7 8 9 10..... were sent and 2 was reorderd....and assume 
>>> we are using delayed ACKs...and we get a triple duplicate ACK after 
>>> pkt#8 is received. (i.e 3&4--first duplicate ACK, 5&6..second 
>>> duplicate ACK and 7&8...third duplicate ACK.....)...
>>>
>>> so if SACK behaved like this...
>>>
>>> 3&4 SACKEd.... 2 packets out of order received
>>> 5&6 SACKEd....4 packets out of order received.... start fast 
>>> retransmission....as reorderd is greater than 3.... (this is true 
>>> when it comes to marking packets as lost during fast recovery, but 
>>> is it true als for the first retransmission?)
>>>
>>> .. any ideas why this is happening???
>>>
>>>
>>> Thanks in advance,
>>> Oumer
>>>   
>>
>>
>> Could you post some short tcpdump snapshot summaries to 
>> netdev@vger.kernel.org?
>>  
>>
>
>

