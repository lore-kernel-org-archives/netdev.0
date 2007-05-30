From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 12:15:33 -0700
Message-ID: <20070530191533.GB3216@linux-os.sc.intel.com>
References: <20070529180112.GC5411@linux-os.sc.intel.com> <20070530105936.6c988da5.akpm@linux-foundation.org> <20070530112056.0aeb9498@freepuppy> <465DC598.5060407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Venki Pallipadi <venkatesh.pallipadi@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10641 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847AbXE3TS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:18:59 -0400
Content-Disposition: inline
In-Reply-To: <465DC598.5060407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 08:42:32PM +0200, Patrick McHardy wrote:
> Stephen Hemminger wrote:
> >>>Index: linux-2.6.22-rc-mm/net/sched/sch_generic.c
> >>>===================================================================
> >>>--- linux-2.6.22-rc-mm.orig/net/sched/sch_generic.c	2007-05-24 11:16:03.000000000 -0700
> >>>+++ linux-2.6.22-rc-mm/net/sched/sch_generic.c	2007-05-25 15:10:02.000000000 -0700
> >>>@@ -224,7 +224,8 @@
> >>> 	if (dev->tx_timeout) {
> >>> 		if (dev->watchdog_timeo <= 0)
> >>> 			dev->watchdog_timeo = 5*HZ;
> >>>-		if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> >>>+		if (!mod_timer(&dev->watchdog_timer,
> >>>+			       round_jiffies(jiffies + dev->watchdog_timeo)))
> >>> 			dev_hold(dev);
> >>> 	}
> >>> }
> >>
> >>Please cc netdev on net patches.
> >>
> >>Again, I worry that if people set the watchdog timeout to, say, 0.1 seconds
> >>then they will get one second, which is grossly different.
> >>
> >>And if they were to set it to 1.5 seconds, they'd get 2.0 which is pretty
> >>significant, too.
> > 
> > 
> > Alternatively, we could change to a timer that is pushed forward after each
> > TX, maybe using hrtimer and hrtimer_forward().  That way the timer would
> > never run in normal case.
> 
> 
> It seems wasteful to add per-packet overhead for tx timeouts, which
> should be an exception. Do drivers really care about the exact
> timeout value? Compared to a packet transmission time its incredibly
> long anyways ..

I agree. Doing a mod_timer or hrtimer_forward to push forward may add to the
complexity depending on how often TX happens.

Are the drivers really worried about exact timeouts here? Can we use rounding
for the timers that are more than a second, at least?

Thanks,
Venki
