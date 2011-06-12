From: Ondrej Zary <linux@rainbow-software.org>
Subject: 3c503: fix broken IRQ autoprobing
Date: Sun, 12 Jun 2011 21:40:49 +0200
Message-ID: <201106122140.51776.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix broken IRQ autoprobing in 3c503 driver:
 - improper IRQ freeing (does not free IRQs causes WARN)
 - missing break when an working IRQ is found

The driver works with this patch.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.39-rc2-orig/drivers/net/3c503.c	2011-04-06 03:30:43.000000000 +0200
+++ linux-2.6.39-rc2/drivers/net/3c503.c	2011-06-12 21:29:47.000000000 +0200
@@ -412,7 +412,7 @@ el2_open(struct net_device *dev)
 		outb_p(0x04 << ((*irqp == 9) ? 2 : *irqp), E33G_IDCFR);
 		outb_p(0x00, E33G_IDCFR);
 		msleep(1);
-		free_irq(*irqp, el2_probe_interrupt);
+		free_irq(*irqp, &seen);
 		if (!seen)
 			continue;
 
@@ -422,6 +422,7 @@ el2_open(struct net_device *dev)
 			continue;
 		if (retval < 0)
 			goto err_disable;
+		break;
 	} while (*++irqp);
 
 	if (*irqp == 0) {


-- 
Ondrej Zary
