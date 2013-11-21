From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Thu, 21 Nov 2013 22:51:09 +0100
Message-ID: <871u298lv6.fsf@natisbad.org>
References: <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	<20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org>
	<20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:59240 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab3KUVvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 16:51:40 -0500
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp6-g21.free.fr (Postfix) with ESMTP id 751D3822B0
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 22:51:25 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Willy Tarreau <w@1wt.eu> writes:

> OK it paid off. And very well :-)
>
> I did it at once and it worked immediately. I generally don't like this
> because I always fear that some bug was left there hidden in the code. I have
> only tested it on the Mirabox, so I'll have to try on the OpenBlocks AX3-4 and
> on the XP-GP board for some SMP stress tests.
>
> I upgraded my Mirabox to latest Linus' git (commit 5527d151) and compared
> with and without the patch.
>
>   without :
>       - need at least 12 streams to reach gigabit.
>       - 60% of idle CPU remains at 1 Gbps
>       - HTTP connection rate on empty objects is 9950 connections/s
>       - cumulated outgoing traffic on two ports reaches 1.3 Gbps
>
>   with the patch :
>       - a single stream easily saturates the gigabit
>       - 87% of idle CPU at 1 Gbps (12 streams, 90% idle at 1 stream)
>       - HTTP connection rate on empty objects is 10250 connections/s
>       - I saturate the two gig ports at 99% CPU, so 2 Gbps sustained output.
>
> BTW I must say I was impressed to see that big an improvement in CPU
> usage between 3.10 and 3.13, I suspect some of the Tx queue improvements
> that Eric has done in between account for this.
>
> I cut the patch in 3 parts :
>    - one which reintroduces the hidden bits of the driver
>    - one which replaces the timer with the IRQ
>    - one which changes the default Tx coalesce from 16 to 4 packets
>      (larger was preferred with the timer, but less is better now).
>
> I'm attaching them, please test them on your device.

Well, on the RN102 (Armada 370), I get the same results as with your
previous patch, i.e. netperf and nginx saturate the link. Apache still
lagging behind though.

> Note that this is *not* for inclusion at the moment as it has not been
> tested on the SMP CPUs.

I tested it on my RN2120 (2-core armada XP): I got no problem and the
link saturated w/ apache, nginx and netperf. Good work!

Cheers,

a+
