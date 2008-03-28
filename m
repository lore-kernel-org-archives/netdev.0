From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 1/1] smc91x driver: fix bug: print warning only in interrupt mode
Date: Fri, 28 Mar 2008 14:52:41 -0700
Message-ID: <200803282152.m2SLqfmg012431@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49036 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756327AbYC1Vxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_item_id=3956

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc91x.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode drivers/net/smc91x.c
--- a/drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode
+++ a/drivers/net/smc91x.c
@@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq
 	SMC_SET_INT_MASK(lp, mask);
 	spin_unlock(&lp->lock);
 
+#ifndef CONFIG_NET_POLL_CONTROLLER
 	if (timeout == MAX_IRQ_LOOPS)
 		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
 		       dev->name, mask);
+#endif
 	DBG(3, "%s: Interrupt done (%d loops)\n",
 	       dev->name, MAX_IRQ_LOOPS - timeout);
 
_
