From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] Make net watchdog timers 1 sec jiffy aligned
Date: Wed, 30 May 2007 10:59:36 -0700
Message-ID: <20070530105936.6c988da5.akpm@linux-foundation.org>
References: <20070529180112.GC5411@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:47303 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753951AbXE3R7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:59:39 -0400
In-Reply-To: <20070529180112.GC5411@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 11:01:13 -0700
Venki Pallipadi <venkatesh.pallipadi@intel.com> wrote:

> round_jiffies for net dev watchdog timer.
> 
> Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
> 
> Index: linux-2.6.22-rc-mm/net/sched/sch_generic.c
> ===================================================================
> --- linux-2.6.22-rc-mm.orig/net/sched/sch_generic.c	2007-05-24 11:16:03.000000000 -0700
> +++ linux-2.6.22-rc-mm/net/sched/sch_generic.c	2007-05-25 15:10:02.000000000 -0700
> @@ -224,7 +224,8 @@
>  	if (dev->tx_timeout) {
>  		if (dev->watchdog_timeo <= 0)
>  			dev->watchdog_timeo = 5*HZ;
> -		if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
> +		if (!mod_timer(&dev->watchdog_timer,
> +			       round_jiffies(jiffies + dev->watchdog_timeo)))
>  			dev_hold(dev);
>  	}
>  }

Please cc netdev on net patches.

Again, I worry that if people set the watchdog timeout to, say, 0.1 seconds
then they will get one second, which is grossly different.

And if they were to set it to 1.5 seconds, they'd get 2.0 which is pretty
significant, too.
