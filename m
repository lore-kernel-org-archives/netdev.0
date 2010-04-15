From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH] net: small cleanup of lib8390
Date: Thu, 15 Apr 2010 17:51:23 +0530
Message-ID: <201004151751.23899.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Jeff Garzik <jeff@garzik.org>
To: Paul Gortmaker <p_gortmaker@yahoo.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37355 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab0DOMTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 08:19:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the always true #if 1. Also the unecessary re-test of ei_local->irqlock
and the unreachable printk format string.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 56f66f4..6e1dcd3 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -445,14 +445,14 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 	if (ei_local->irqlock)
 	{
-#if 1 /* This might just be an interrupt for a PCI device sharing this line */
-		/* The "irqlock" check is only for testing. */
-		printk(ei_local->irqlock
-			   ? "%s: Interrupted while interrupts are masked! isr=%#2x imr=%#2x.\n"
-			   : "%s: Reentering the interrupt handler! isr=%#2x imr=%#2x.\n",
+		/*
+		 * This might just be an interrupt for a PCI device sharing
+		 * this line
+		 */
+		printk("%s: Interrupted while interrupts are masked!"
+			   " isr=%#2x imr=%#2x.\n",
 			   dev->name, ei_inb_p(e8390_base + EN0_ISR),
 			   ei_inb_p(e8390_base + EN0_IMR));
-#endif
 		spin_unlock(&ei_local->page_lock);
 		return IRQ_NONE;
 	}
