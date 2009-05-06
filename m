From: Patrick McHardy <kaber@trash.net>
Subject: Re: bond + tc regression ?
Date: Wed, 06 May 2009 15:31:06 +0200
Message-ID: <4A01911A.1090709@trash.net>
References: <20090505174135.GA29716@francoudi.com> <20090506061010.GA4571@ff.dom.local> <20090506103616.GA25750@francoudi.com> <20090506104808.GA6115@ff.dom.local> <20090506131117.GA10105@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43630 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbZEFNbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 09:31:09 -0400
In-Reply-To: <20090506131117.GA10105@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko wrote:
> On Wed, May 06, 2009 at 10:48:08AM +0000, Jarek Poplawski wrote:
> 
>>>>>> ifconfig -a
>>>>> bond0     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
>>>>>           inet addr:xxx.xxx.135.44  Bcast:xxx.xxx.135.47  Mask:255.255.255.248
>>>>>           inet6 addr: fe80::21b:24ff:febd:e9cc/64 Scope:Link
>>>>>           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>>>>>           RX packets:436076190 errors:0 dropped:391250 overruns:0 frame:0
>>>>>           TX packets:2620156321 errors:0 dropped:0 overruns:0 carrier:0
>>>>>           collisions:0 txqueuelen:0
>>>>>           RX bytes:4210046233 (3.9 GiB)  TX bytes:2520272242 (2.3 GiB)
>>>> Could you try e.g.: ifconfig bond0 txqueuelen 1000
>>>> before tc qdisc add?
>>> The drops on ifconfig are not increasing - these numbers are there from some tests made
>>> before.
>>>
>> I'm not sure what do you mean? IMHO you don't use qdiscs properly,
>> so any TX problems end with drops. (Older kernel versions could mask
>> this problem with requeuing.)
> 
> Apologies, my bad, I misread what you wrote.
> 
> txqueuelen 1000 fixes the qdisc drops. I didn't notice that bond interfaces have it set to 0 by default.

The fifos use a queue length of 1 when the tx_queue_len is zero (which
was added as a workaround for similar problems a long time ago). Perhaps
we should instead refuse these broken configurations or at least print
a warning.
