From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Tue, 28 Oct 2008 11:37:41 +0100
Message-ID: <20081028103741.GA22319@elte.hu>
References: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk> <20081027183312.GD11494@elte.hu> <20081027193933.GB2590@ioremap.net> <20081027.124848.163119274.davem@davemloft.net> <1225189462.4903.238.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net,
	alan@lxorguk.ukuu.org.uk, jkosina@suse.cz,
	akpm@linux-foundation.org, a.p.zijlstra@chello.nl, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47233 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbYJ1Kig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 06:38:36 -0400
Content-Disposition: inline
In-Reply-To: <1225189462.4903.238.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Mike Galbraith <efault@gmx.de> wrote:

> ..removing the overhead from .27 does not produce the anticipated 
> result despite a max context switch rate markedly above that of 
> 2.6.26.
> 
> There lies an as yet unaddressed regression IMBHO.  The hrtick has 
> been addressed.  It sucked at high frequency, and it's gone.  The 
> added math overhead in .27 hurt some too, and is now history as 
> well.

thanks Mike for the _extensive_ testing and bug hunting session you've 
done in the past couple of weeks! All the relevant fixlets you found 
are now queued up properly in sched/urgent, correct?

What's your gut feeling, is that remaining small regression scheduler 
or networking related?

i'm cutting the ball in half and i'm passing over one half of it to 
the networking folks, because your numbers show _huge_ sensitivity in 
this workload, depending on networking settings:

> To really illustrate rockiness, cutting network config down from distro
> lard-ball to something leaner and meaner took SMP throughput from this
> (was only testing netperf at that time) on 19 Aug..
> 
> 2.6.22.19 pinned
> 16384  87380  1        1       300.00   59866.40   

> 2.6.22.19 (also pinned)
> 16384  87380  1        1       60.01    94179.12

> 2.6.22.19 (also pinned)
> 16384  87380  1        1       60.01    111272.55  1.00

any scheduler micro-overhead detail is going to be a drop in the 
ocean, compared to such huge variations. We could change the scheduler 
to the old O(N) design of the 2.2 kernel and the impact of that would 
be a blip on the radar, compared to the overhead shown above.

	Ingo
