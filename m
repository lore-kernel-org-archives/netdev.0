From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 15:28:01 -0600
Message-ID: <20131211212801.GB8283@sbohrermbp13-local.rgmadvisors.com>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
 <20131211185438.GC4371@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:53108 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab3LKV2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:28:05 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so5495211yhl.20
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 13:28:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131211185438.GC4371@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 07:54:39PM +0100, Richard Cochran wrote:
> On Wed, Dec 11, 2013 at 12:24:25PM -0600, Shawn Bohrer wrote:
> > From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> > 
> > This adds a PHC to the mlx4_en driver.  This is largely based off of the
> > e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
> > very similar.  One thing I am unsure about is that in the e1000e driver
> > they protect the timecounter code with a spinlock because the hardware
> > reports the time in two 32bit registers.  The Mellanox code looks
> > similar however the existing timecounter code in the mlx4_en driver
> > wasn't protected with a lock so I left the lock out here as well.
> 
> Before, there were only three call sites,
> 
> grep -nH -e timecounter_ *
> en_clock.c:108:	nsec = timecounter_cyc2time(&mdev->clock, timestamp);
> en_clock.c:131:	timecounter_init(&mdev->clock, &mdev->cycles,
> en_clock.c:148:		timecounter_read(&mdev->clock);
> 
> and so perhaps the locking was unnecessary (but maybe not).
> In any case, the code that you added definitely needs locks.
> 

Yeah, that looked sketchy to me.  I've added the locks.

> > Additionally here the mlx4_en_phc_adjfreq() method simply returns
> > -EOPNOTSUPP because I don't have the relevant hardware documentation on
> > how to do this.  I'm hoping one of the Mellanox developers can either
> > provide this documentation or provide a patch to implement that
> > function.
> 
> Since the code already uses timecounter_read to convert clock ticks
> into nanoseconds, why not simply adjust the 'mult' as other drivers
> do?
>
> [ If the clock is easily adjustable in hardware, then, by all means,
>   do it that way. ]

Awesome, I totally missed this.  I've updated my code to do this for
now and if there is a better way the Mellanox guys can chime in.

>  
> > This is minimally tested at this point but Documentation/ptp/testptp
> > appears to work on a Mellanox ConnectX-3 card.
> 
> Once you have the adjustment in place, then you can try it with
> linuxptp.

Yep, that is the goal of this exercise.  I should have a v2 patch with
these changes after I do some more testing.

Thanks,
Shawn
