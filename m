From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 09:28:54 -0800
Message-ID: <4ED51656.3030802@hp.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com> <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com> <1322550138.2970.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:43960 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab1K2R24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 12:28:56 -0500
In-Reply-To: <1322550138.2970.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2011 11:02 PM, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 =C3=A0 05:23 +0100, Dave Taht a =C3=A9crit =
:
>>> In this test 100 netperf TCP_STREAMs were started to saturate the l=
ink.
>>> A single instance of a netperf TCP_RR was run with high priority se=
t.
>>> Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size se=
t to
>>> 1024.  tps for the high priority RR is listed.
>>>
>>> No BQL, tso on: 3000-3200K bytes in queue: 36 tps
>>> BQL, tso on: 156-194K bytes in queue, 535 tps
>>
>>> No BQL, tso off: 453-454K bytes int queue, 234 tps
>>> BQL, tso off: 66K bytes in queue, 914 tps
>>
>>
>> Jeeze. Under what circumstances is tso a win? I've always
>> had great trouble with it, as some e1000 cards do it rather badly.

It is a win when one is sending bulk(ish) data and wish to avoid the=20
trips up and down the protocol stack to save CPU cycles.

TSO is sometimes called "poor man's Jumbo Frames"  as it seeks to=20
achieve the same goal - fewer trips down the protocol stack per KB of=20
data transferred.

>> I assume these are while running at GigE speeds?
>>
>> What of 100Mbit? 10GigE? (I will duplicate your tests
>> at 100Mbit, but as for 10gigE...)
>>
>
> TSO on means a low priority 65Kbytes packet can be in TX ring right
> before the high priority packet. If you cant afford the delay, you lo=
se.
>
> There is no mystery here.
>
> If you want low latencies :
> - TSO must be disabled so that packets are at most one ethernet frame=
=2E
> - You adjust BQL limit to small value
> - You even can lower MTU to get even more better latencies.
>
> If you want good throughput from your [10]GigE and low cpu cost, TSO
> should be enabled.

Outbound throughput. If you want good inbound throughput you want GRO/L=
RO.

> If you want to be smart, you could have a dynamic behavior :
>
> Let TSO on as long as no high priority low latency producer is runnin=
g
> (if low latency packets are locally generated)

I'd probably leave that to the administrator rather than try to clutter=
=20
things with additional logic.

*If* I were to add additional logic, I might have an interface=20
communicate its "maximum TSO size" up the stack in a manner to too=20
dissimilar from MTU.  That way one can control just how much time a=20
TSO'd segment would consume.

rick jones
