From: akpm@linux-foundation.org
Subject: [patch 15/21] forcdeth: increase max_interrupt_work
Date: Mon, 22 Sep 2008 14:52:24 -0700
Message-ID: <200809222152.m8MLqO0X031981@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	joe.korty@ccur.com, aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48660 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754036AbYIVV6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:58:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Korty <joe.korty@ccur.com>

This eliminates the following often-generated warning from my 64 bit
Opteron SMP test stand:

	eth0: too many iterations (6) in nv_nic_irq

According to the web, the problem is that the forcedeth driver has a
too-low value for max_interrupt_work.  Grepping the kernel I see that
forcedeth has the second lowest value of all ethernet drivers (ie, 6). 
Most are in the 20-40 range.  So this patch increases this a bit, from 6
to 15 (at 15 forcedeth becomes the driver with third-lowest
max_interrupt_work value).

My test stand, which used to print out the above warnings repetitively
whenever it was under heavy net load, no longer does so.

Signed-off-by: Joe Korty <joe.korty@ccur.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcdeth-increase-max_interrupt_work drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcdeth-increase-max_interrupt_work
+++ a/drivers/net/forcedeth.c
@@ -818,7 +818,7 @@ struct fe_priv {
  * Maximum number of loops until we assume that a bit in the irq mask
  * is stuck. Overridable with module param.
  */
-static int max_interrupt_work = 5;
+static int max_interrupt_work = 15;
 
 /*
  * Optimization can be either throuput mode or cpu mode
_
