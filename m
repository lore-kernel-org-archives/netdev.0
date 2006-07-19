From: Oumer Teyeb <oumer@kom.aau.dk>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Wed, 19 Jul 2006 19:32:10 +0200
Message-ID: <44BE6C9A.1030601@kom.aau.dk>
References: <44BD38B1.1080807@kom.aau.dk> <20060719132719.GA22143@ms2.inr.ac.ru> <44BE498F.9070001@kom.aau.dk> <20060719154934.GA29877@ms2.inr.ac.ru> <44BE5E89.1020002@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaz.kom.auc.dk ([130.225.51.10]:4490 "EHLO zaz.kom.auc.dk")
	by vger.kernel.org with ESMTP id S1030206AbWGSRc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 13:32:27 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <44BE5E89.1020002@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oumer Teyeb wrote:

> Hi,
>
> Alexey Kuznetsov wrote:
>
>> Condition triggering start of fast retransmit is the same.
>> The behaviour while retransmit is different. FACKless code
>> behaves more like NewReno.
>>  
>>
> Ok, that is a good point!!  Now at least I can convince myself the 
> CDFs for the first retransmissions showing that SACK leads to earlier 
> retransmissions than no SACK are not wrong....and I can even convince 
> myself that this is the real reason behind sack/fack's performance 
> degredation for the case of no timestamps,:-)... ...

Actually, then the increase in the number of retransmissions and the 
increase in teh download time from no SACK - SACK for timestamp case 
seems to make sense also...my reasoning is like this...if there is 
timestamps, that means there is reordering detection...hence the number 
retransmissions are reduced because we avoid the time spent in fast 
recovery.... when we introduce SACK on top of timestamps, we enter fast 
retransmits earlier than no SACK case as we seem to agree, and since the 
timestamp reduces the number of retransmission once we are in fast 
recovery, the retransmissions we see are basically the first few 
retransmissions that made us enter the false fast retransmits, so we 
have a little increase in the retransmissions and a little increase in 
the download times... but when no timestamps are used, there is no 
reordering detection and so SACK leads to less number of retransmissions 
because it retransmits selectively, but it doesnt improve the download 
time because it enters fast retransmit eralier than the no SACK and in 
this case the fast retransmits are very costly because they are not 
detected lead to window reduction.... am I making sense?:-).... still 
the DSACK case is puzzling me....

Regards,
Oumer
