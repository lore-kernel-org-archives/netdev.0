From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Tue, 18 May 2010 16:22:00 +0200
Message-ID: <4BF2A288.7040304@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl>	 <1274042826.2299.26.camel@edumazet-laptop>  <4BF05FC2.4020804@ans.pl> <1274045180.2299.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:59214 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab0EROWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 10:22:16 -0400
In-Reply-To: <1274045180.2299.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-16 23:26, Eric Dumazet wrote:

<CUT>

>> My normal workload is TCP and UDP based so if it is only ICMP then t=
here
>> is no problem. Actually I have noticeably more UDP traffic than an
>> average network, mainly because of LWAPP/CAPWAP, so I'm interested i=
n
>> good performance for both TCP and UDP.
>>
>> During my initial tests ICMP ping showed the same behavior like UDP/=
TCP
>> with iperf, so I sticked with it. I'll redo everyting with UDP and T=
CP
>> of course. :)
>>
>>>> BTW: With a normal router workload, should I expect big performanc=
e drop
>>>> when receiving and forwarding the same packet using different CPUs=
?
>>>> Bonding provides very important functionality, I'm not able to dro=
p it. :(
>>>>
>>>
>>> Not sure what you mean by forwarding same packet using different CP=
Us.
>>> You probably meant different queues, because in normal case, only o=
ne
>>> cpu is involved (the one receiving the packet is also the one
>>> transmitting it, unless you have congestion or trafic shaping)
>>
>> I mean to receive it on a one CPU and to send it on a different one.=
 I
>> would like to assing different vectors (eth1-0 .. eth1-4) to differe=
nt
>> CPUs, but with bnx2x+bonding packets are received on queues 1-4 (eth=
1-1
>> .. eth1-4) and sent from queue 0 (eth1-0). So, for a one packet, two
>> different CPUs will be involved (RX on q1-q4, TX on q0).
>
> As I said, (unless you use RPS), one forwarded packet only uses one C=
PU.
> How tx queue is selected is another story. We try to do a 1-1 mapping=
=2E

OK, but with multi-queue NIC, I can assign each queue to a different=20
CPU. So, while forwarding packets from a flow, I would like to assign=20
the same queue on both input and output.

>>> If you have 4 cpus, you can use following patch and have a transpar=
ent
>>> bonding against multiqueue.
>>
>> Thanks! If I get it right: with the patch, packets should be sent us=
ing
>> the same CPU (queue?) that was used when receiving?
>
> Yes, for forwarding loads.
>
> (You might use 5 or 8 instead of 4, because its not clear to me if bn=
x2
> has 5 txqueues or 4 in your case)

Thank you. What happens if I set it to a lower/bigger value, than=20
avaliable txqueues in a NIC?

Best regards,

			Krzysztof Ol=C4=99dzki
