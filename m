From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: Strange TCP behavior over HSDPA
Date: Tue, 29 Dec 2009 15:30:28 +0100
Message-ID: <4B3A1284.2030101@gmail.com>
References: <20091229083050.GA7209@ff.dom.local> <4B39D30F.8090006@gmail.com> <20091229105748.GB7209@ff.dom.local> <20091229121624.GC7209@ff.dom.local> <20091229133620.GA9552@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:43833 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbZL2OeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 09:34:11 -0500
Received: by ewy19 with SMTP id 19so2750612ewy.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 06:34:09 -0800 (PST)
In-Reply-To: <20091229133620.GA9552@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 29.12.2009 14:36, skrev Jarek Poplawski:
> On Tue, Dec 29, 2009 at 12:16:24PM +0000, Jarek Poplawski wrote:
>    
>> On Tue, Dec 29, 2009 at 10:57:48AM +0000, Jarek Poplawski wrote:
>>      
>>> Did you try to turn off TCP window scaling btw? Anyway, under the
>>> tunnel ([2]), when SACK worked, it saved you a lot of retransmits.
>>>        
>> Hmm... Actually, after re-checking, there weren't much more of those
>> retransmits at all. In [1] there was one more packet lost, so it took
>> a bit longer. In [2] (with SACK) the retransmit started earlier and
>> the rcv window was unchanged. So, it rather looks like differences
>> in timing of TCP recovery techniques.
>>      
> Hmm#2... On the other hand, I can imagine cases with a larger data
> loss, where working SACK should really save on retransmits.
>
> Jarek P.
>    
Thanks for all your comments. I have not tried to disable window 
scaling, but will try that as soon as possible. I also noticed the 
second packet loss in [1], but I don't think it affected the situation 
to much. In similar packet captures, the transfer without the tunnel has 
only lost one packet and the throughput drop has been just as 
significant as in [1]. It rather seems to be, as you point out, 
differences in timing of the recovery techniques, probably between this 
accelerator and the server.

However, I find it a bit strange the dupAcks are sent back to the 
server. Based on my, I must admit limited, knowledge of accelerators, 
they will buffer and ACK packets if they for example are responsible for 
retransmissions. But again, maybe it uses the dupAcks to tell the server 
to slow down and then simply discards the retransmitted packet.

-Kristian
