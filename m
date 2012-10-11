From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 14:59:12 +0200
Message-ID: <1349960352.21172.9033.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <506ED18C.3010009@gmail.com> <20121005140556.GQ4625@n2100.arm.linux.org.uk>
	 <506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org>
	 <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	 <yw1xpq4ppcju.fsf@unicorn.mansr.com>
	 <1349949638.21172.8445.camel@edumazet-glaptop>
	 <1349950926.21172.8521.camel@edumazet-glaptop>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
	 <1349952970.1232.5.camel@sakura.staff.proxad.net>
	 <1349954899.21172.8728.camel@edumazet-glaptop>
	 <1349956055.1232.9.camel@sakura.staff.proxad.net>
	 <1349956456.21172.8820.camel@edumazet-glaptop>
	 <1349959881.1232.44.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-arm-kernel@lists.infradead.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34618 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755968Ab2JKM7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:59:17 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so959670bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 05:59:15 -0700 (PDT)
In-Reply-To: <1349959881.1232.44.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 14:51 +0200, Maxime Bizon wrote:

> Hey I cannot go back in time, when that hardware was built in 2004 (mips
> @250Mhz), it was considered good, and we did manufacture a lot of it, so
> it's still maintained.
> 
> People run recent kernels on older hardware because they are *encouraged
> to do so*.
> 
> I fought inside my company to be good kernel citizen, not using
> proprietary BSP, rewrite & mainline the drivers, because that was the
> community promise: mainline it, we will support it for you, you will get
> the latest kernel features for free.
> 
> 
> That worked, but with some drawbacks:
> 
>  - kernel footprint grew that much (we started from 2.4) that it does
> not fit in device flash anymore
> 
>  - performance took a hit each time we upgrade, mostly because of cache
> footprint growth.
> 
>  - as kernel footprint grew, available RAM for conntrack & route cache
> entries was smaller each time
> 
> 
> But I had to stop upgrading after 2.6.20. Everything below is not
> anybody's fault. Bloat is unavoidable for software project that big.
> 
> I'm perfectly ok with that, but I don't want to be ridiculed for running
> mainline kernel on old hardware.

Hmm, I am sorry if you felt that, it was not my intent.

> 
> 
> > Adding get_unaligned() everywhere in linux network stacks is not an
> > option.
> > 
> > We actually want to be able to read the code and fix the bugs, not only
> > run it on a cheap low end router.
> 
> That was not a request, I just needed a clarification. 
> 
> Documentation/unaligned-memory-access.txt does not say it's a big no-no,
> it says you can give unaligned pointers to the networking stack if you
> arch can do unaligned access (with an "efficiency" notion).
> 
> MIPS and ARM have a software handler for this, and performance wise in
> my case it's better to take the faults, a driver writer may think a
> benchmark will dictate what to do.
> 

Sure, but all this discussion started because one arch apparently did
not like these mis alignments, and some people complained that network
guys would not add _needed_ get_unaligned_xxx() wrappers ...

So far, linux is 20 years old, I dont think we are going to add wrappers
right now. Machines that could have cared are dying anyway.

Please note we still support NET_IP_ALIGN, even if its 0 on x86.
