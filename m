From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 11:20:56 -0700
Message-ID: <20070530112056.0aeb9498@freepuppy>
References: <20070529180112.GC5411@linux-os.sc.intel.com>
	<20070530105936.6c988da5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Venki Pallipadi <venkatesh.pallipadi@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:59286 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbXE3Sc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 14:32:26 -0400
In-Reply-To: <20070530105936.6c988da5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 10:59:36 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 29 May 2007 11:01:13 -0700
> Venki Pallipadi <venkatesh.pallipadi@intel.com> wrote:
> 
> > round_jiffies for net dev watchdog timer.
> > 
> > Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
> > 
> > Index: linux-2.6.22-rc-mm/net/sched/sch_generic.c
> > ===================================================================
> > --- linux-2.6.22-rc-mm.orig/net/sched/sch_generic.c	2007-05-24 11:16:03.000000000 -0700
> > +++ linux-2.6.22-rc-mm/net/sched/sch_generic.c	2007-05-25 15:10:02.000000000 -0700
> > @@ -224,7 +224,8 @@
> >  	if (dev->tx_timeout) {
> >  		if (dev->watchdog_timeo <= 0)
> >  			dev->watchdog_timeo = 5*HZ;
> > -		if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> > +		if (!mod_timer(&dev->watchdog_timer,
> > +			       round_jiffies(jiffies + dev->watchdog_timeo)))
> >  			dev_hold(dev);
> >  	}
> >  }
> 
> Please cc netdev on net patches.
> 
> Again, I worry that if people set the watchdog timeout to, say, 0.1 seconds
> then they will get one second, which is grossly different.
> 
> And if they were to set it to 1.5 seconds, they'd get 2.0 which is pretty
> significant, too.

Alternatively, we could change to a timer that is pushed forward after each
TX, maybe using hrtimer and hrtimer_forward().  That way the timer would
never run in normal case.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
