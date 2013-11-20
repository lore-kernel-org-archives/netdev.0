From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 20:26:16 +0100
Message-ID: <87zjoyoox3.fsf@natisbad.org>
References: <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	<20131117141940.GA18569@1wt.eu>
	<1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	<20131120191145.GP8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:42614 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193Ab3KTT0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 14:26:39 -0500
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp5-g21.free.fr (Postfix) with ESMTP id C4EEDD48231
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 20:26:29 +0100 (CET)
In-Reply-To: <20131120191145.GP8581@1wt.eu> (Willy Tarreau's message of "Wed,
	20 Nov 2013 20:11:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Willy Tarreau <w@1wt.eu> writes:

> first, thanks for all these tests.
>
> On Wed, Nov 20, 2013 at 12:53:43AM +0100, Arnaud Ebalard wrote:
> (...)
>> In the end, here are the conclusions *I* draw from this test session,
>> do not hesitate to correct me:
>> 
>>  - Eric, it seems something changed in linus tree betwen the beginning
>>    of the thread and now, which somehow reduces the effect of the
>>    regression we were seen: I never got back the 256KB/s.
>>  - You revert patch still improves the perf a lot
>>  - It seems reducing MVNETA_TX_DONE_TIMER_PERIOD does not help
>>  - w/ your revert patch, I can confirm that mvneta driver is capable of
>>    doing line rate w/ proper tweak of TCP send window (256KB instead of
>>    4M)
>>  - It seems I will I have to spend some time on the SATA issues I
>>    previously thought were an artefact of not cleaning my tree during a
>>    debug session [1], i.e. there is IMHO an issue.
>
> Could you please try Eric's patch that was just merged into Linus' tree
> if it was not yet in the kernel you tried :
>
>   98e09386c0e  tcp: tsq: restore minimal amount of queueing

I have it in my quilt set.


> For me it restored the original performance (I saturate the Gbps with
> about 7 concurrent streams).
>
> Further, I wrote the small patch below for mvneta. I'm not sure it's
> smp-safe but it's a PoC. In mvneta_poll() which currently is only called
> upon Rx interrupt, it tries to flush all possible remaining Tx descriptors
> if any. That significantly improved my transfer rate, now I easily achieve
> 1 Gbps using a single TCP stream on the mirabox. Not tried on the AX3 yet.
>
> It also increased the overall connection rate by 10% on empty HTTP responses
> (small packets), very likely by reducing the dead time between some segments!
>
> You'll probably want to give it a try, so here it comes.

hehe, I was falling short of patches to test tonight ;-) I will give it
a try now.

Cheers,

a+
