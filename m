From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 14:24:53 -0700
Message-ID: <450F0EA5.2020109@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com>	<20060918.003938.26278728.davem@davemloft.net>	<450ED337.8000700@hp.com> <20060918204105.GA31333@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:41131 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1030187AbWIRVY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 17:24:56 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060918204105.GA31333@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
> Of course, number of ACK increases. It is the goal. :-)
> 
>>unpleasant increase in service demands on something like a "burst 
>>enabled" (./configure --enable-burst) netperf TCP_RR test:
>>
>>netperf -t TCP_RR -H foo -- -b N   # N > 1
> 
> foo=localhost

There isn't any sort of clever short-circuiting in loopback is there?  I 
do like the convenience of testing things over loopback, but always fret 
about not including drivers and actual hardware interrupts etc.

> b	patched		orig
> 2	105874.83	105143.71
> 3	114208.53	114023.07
> 4	120493.99	120851.27
> 5	128087.48	128573.33
> 10	151328.48	151056.00
 >
> Probably, the test is done wrong. But I see no difference.

Regardless, kudos for running the test.  The only thing missing is the 
-c and -C options to enable the CPU utilization measurements which will 
then give the service demand on a CPU time per transaction basis.  Or 
was this a UP system that was taken to CPU saturation?

>>to increase as a result.   Pipelined HTTP would be like that, some NFS 
>>over TCP stuff too, maybe X traffic,
> 
> 
> X will be excited about better latency.
> 
> What's about protocols not interested in latency, they will be a little
> happier, if transactions are processed asynchronously.

What i'm thinking about isn't so much about the latency as it is the 
aggregate throughput a system can do with lots of these 
protocols/connections going at the same time.  Hence the concern about 
increases in service demand.

> But actually, it is not about increasing/decreasing number of ACKs.
> It is about killing that pain in ass which we used to have because
> we pretended to be too smart.

:)

rick jones
