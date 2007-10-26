From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] drivers/net/irda/au1k_ir: fix obvious irq handler bugs
Date: Fri, 26 Oct 2007 05:40:29 -0400 (EDT)
Message-ID: <bdce59bb00f2095c934e9931df2689e636673622.1193390975.git.jeff@garzik.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Cc: akpm@linux-foundation.org, samuel@sortiz.org,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:60316 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758668AbXJZJlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 05:41:00 -0400
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

interrupt handlers return a return value these days.

Also, kill always-true test and unneeded void* cast.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/net/irda/au1k_ir.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 4dbdfaa..a1e4508 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -627,19 +627,16 @@ static int au1k_irda_rx(struct net_device *dev)
 }
 
 
-void au1k_irda_interrupt(int irq, void *dev_id)
+static irqreturn_t au1k_irda_interrupt(int dummy, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-
-	if (dev == NULL) {
-		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
-		return;
-	}
+	struct net_device *dev = dev_id;
 
 	writel(0, IR_INT_CLEAR); /* ack irda interrupts */
 
 	au1k_irda_rx(dev);
 	au1k_tx_ack(dev);
+
+	return IRQ_HANDLED;
 }
 
 
-- 
1.5.2.4

