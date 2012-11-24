From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Sat, 24 Nov 2012 15:43:36 -0800
Message-ID: <1353800616.2590.4562.camel@edumazet-glaptop>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com>  <loom.20121124T213422-650@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:49256 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab2KXXns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 18:43:48 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so7196296iay.19
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 15:43:46 -0800 (PST)
In-Reply-To: <loom.20121124T213422-650@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-24 at 20:42 +0000, Tino Keitel wrote:
> Paul Gortmaker <paul.gortmaker <at> windriver.com> writes:
> 
> > 
> > On 12-11-23 10:58 AM, Keitel, Tino (ALC NetworX GmbH) wrote:
> > > Hi,
> > > 
> > > commit d8a0f1b0af67679bba886784de10d8c21acc4e0e causes the following
> > > trace on a Freescale RDB8313 board:
> > 
> > Thanks for the report.
> > 
> > > 
> > > NETDEV WATCHDOG: eth1 (fsl-gianfar): transmit queue 0 timed out
> > > ------------[ cut here ]------------
> > > WARNING:
> > > at /home/keitelt1/src/git/linux-stable/net/sched/sch_generic.c:255
> > > Modules linked in:
> > > NIP: c02448b0 LR: c02448b0 CTR: c01c19b8
> > > REGS: c7ffbe40 TRAP: 0700   Not tainted  (3.7.0-rc6-rt18)
> >                                             ^^^^^^^^^^^^^^^
> > I almost overlooked the above.  It would have been nice to
> > see more explicit information on what kernel you are running.
> > I say that because the above concerns me.  For several reasons.
> > 
> > 1) it looks to be not mainline, but preempt_rt
> > 2) There is no RT on 3.7 yet, so I'm assuming this is a custom
> >    forward port of the 250 odd RT patches.  (The RT is 3.6.7-rt18,
> >    i.e. based on the 3.6 gregKH stable tree.)
> 
> Sorry for the confusion. This was a 3.7.0-rc6 tree, and I forgot git clean after
> trying the rt-patches and git reset --hard v3.7.0-rc6, so the localversion file
> for -rt was still present, and the kernel was named 3.7.0-rc6-rt18. If I got
> this right, this should be a normal kernel with just the version file modified.
> 
> I tried kernel 3.3, which doesnt have the issue. I tried 3.4, 3.6.7 and 3.7-rc6,
> which all show the kernel trace and ptp client misbehaviour. I tried 3.4, 3.6.7,
> 3.7-rc6 and 3.6.5-rt18 with the patch I posted, and they were ok.
> 
> The patch I posted is for 3.7-rc6.
> 

Hmm, I wonder if BQL makes a particular bug showing more often.

I see gianfar uses a very small watchdog_timeo of 1 second, while many
drivers use 5 seconds.

What happens if you change this to 5 seconds ?

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 19ac096..3a994f9 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -101,7 +101,7 @@
 
 #include "gianfar.h"
 
-#define TX_TIMEOUT      (1*HZ)
+#define TX_TIMEOUT      (5*HZ)
 
 const char gfar_driver_version[] = "1.3";
 
