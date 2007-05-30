From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 14:10:10 -0700
Message-ID: <20070530211010.GA12616@linux-os.sc.intel.com>
References: <20070530105936.6c988da5.akpm@linux-foundation.org> <20070530112056.0aeb9498@freepuppy> <465DC598.5060407@trash.net> <20070530.125551.41636333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, venkatesh.pallipadi@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52833 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971AbXE3VNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 17:13:42 -0400
Content-Disposition: inline
In-Reply-To: <20070530.125551.41636333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 12:55:51PM -0700, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 30 May 2007 20:42:32 +0200
> 
> > Stephen Hemminger wrote:
> > >>>Index: linux-2.6.22-rc-mm/net/sched/sch_generic.c
> > >>>===================================================================
> > >>>--- linux-2.6.22-rc-mm.orig/net/sched/sch_generic.c	2007-05-24 11:16:03.000000000 -0700
> > >>>+++ linux-2.6.22-rc-mm/net/sched/sch_generic.c	2007-05-25 15:10:02.000000000 -0700
> > >>>@@ -224,7 +224,8 @@
> > >>> 	if (dev->tx_timeout) {
> > >>> 		if (dev->watchdog_timeo <= 0)
> > >>> 			dev->watchdog_timeo = 5*HZ;
> > >>>-		if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> > >>>+		if (!mod_timer(&dev->watchdog_timer,
> > >>>+			       round_jiffies(jiffies + dev->watchdog_timeo)))
> > >>> 			dev_hold(dev);
> > >>> 	}
> > >>> }
> > >>
> > >>Please cc netdev on net patches.
> > >>
> > >>Again, I worry that if people set the watchdog timeout to, say, 0.1 seconds
> > >>then they will get one second, which is grossly different.
> > >>
> > >>And if they were to set it to 1.5 seconds, they'd get 2.0 which is pretty
> > >>significant, too.
> > > 
> > > 
> > > Alternatively, we could change to a timer that is pushed forward after each
> > > TX, maybe using hrtimer and hrtimer_forward().  That way the timer would
> > > never run in normal case.
> > 
> > 
> > It seems wasteful to add per-packet overhead for tx timeouts, which
> > should be an exception. Do drivers really care about the exact
> > timeout value? Compared to a packet transmission time its incredibly
> > long anyways ..
> 
> I agree, this change is absolutely rediculious and is just a blind
> cookie-cutter change made without consideration of what the code is
> doing and what it's requirements are.

I hope I could atleast highlight the issue here despite the cookie-cutter
patch..
On a totally idle system I have something like 85 wakeups for every 5 seconds
which I am trying to reduce (to reduce the power consumption and increase
battery life. And 1 interrupt out of 85 happens to be netdev watchdog timer.

Thanks,
Venki
