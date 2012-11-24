From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: BQL support in gianfar causes network hickup
Date: Sat, 24 Nov 2012 20:42:30 +0000 (UTC)
Message-ID: <loom.20121124T213422-650@post.gmane.org>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de> <50AFA599.9040108@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57395 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab2KXUo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2012 15:44:59 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TcMb1-0001pS-DE
	for netdev@vger.kernel.org; Sat, 24 Nov 2012 21:45:03 +0100
Received: from mnch-5d85cd98.pool.mediaWays.net ([93.133.205.152])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 21:45:03 +0100
Received: from tino.keitel by mnch-5d85cd98.pool.mediaWays.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 21:45:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker <paul.gortmaker <at> windriver.com> writes:

> 
> On 12-11-23 10:58 AM, Keitel, Tino (ALC NetworX GmbH) wrote:
> > Hi,
> > 
> > commit d8a0f1b0af67679bba886784de10d8c21acc4e0e causes the following
> > trace on a Freescale RDB8313 board:
> 
> Thanks for the report.
> 
> > 
> > NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue 0 timed out
> > ------------[ cut here ]------------
> > WARNING:
> > at /home/keitelt1/src/git/linux-stable/net/sched/sch_generic.c:255
> > Modules linked in:
> > NIP: c02448b0 LR: c02448b0 CTR: c01c19b8
> > REGS: c7ffbe40 TRAP: 0700   Not tainted  (3.7.0-rc6-rt18)
>                                             ^^^^^^^^^^^^^^^
> I almost overlooked the above.  It would have been nice to
> see more explicit information on what kernel you are running.
> I say that because the above concerns me.  For several reasons.
> 
> 1) it looks to be not mainline, but preempt_rt
> 2) There is no RT on 3.7 yet, so I'm assuming this is a custom
>    forward port of the 250 odd RT patches.  (The RT is 3.6.7-rt18,
>    i.e. based on the 3.6 gregKH stable tree.)

Sorry for the confusion. This was a 3.7.0-rc6 tree, and I forgot git clean after
trying the rt-patches and git reset --hard v3.7.0-rc6, so the localversion file
for -rt was still present, and the kernel was named 3.7.0-rc6-rt18. If I got
this right, this should be a normal kernel with just the version file modified.

I tried kernel 3.3, which doesnt have the issue. I tried 3.4, 3.6.7 and 3.7-rc6,
which all show the kernel trace and ptp client misbehaviour. I tried 3.4, 3.6.7,
3.7-rc6 and 3.6.5-rt18 with the patch I posted, and they were ok.

The patch I posted is for 3.7-rc6.

Regards,
Tino
