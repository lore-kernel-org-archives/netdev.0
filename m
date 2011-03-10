From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 3/8] macb: convert printk to pr_ and friends
Date: Thu, 10 Mar 2011 10:10:38 +0000
Message-ID: <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34325 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1CJKK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:10:56 -0500
Received: by wya21 with SMTP id 21so1289541wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:10:54 -0800 (PST)
In-Reply-To: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb is already using the dev_dbg() and friends helpers so use pr_foo()
along with a pr_fmt() definition to make the printing a little cleaner.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/macb.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index ae98fee..5d676ad 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "macb: " fmt
 #include <linux/clk.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -175,11 +176,11 @@ static void macb_handle_link_change(struct net_device *dev)
 
 	if (status_change) {
 		if (phydev->link)
-			printk(KERN_INFO "%s: link up (%d/%s)\n",
+			pr_info("%s: link up (%d/%s)\n",
 			       dev->name, phydev->speed,
 			       DUPLEX_FULL == phydev->duplex ? "Full":"Half");
 		else
-			printk(KERN_INFO "%s: link down\n", dev->name);
+			pr_info("%s: link down\n", dev->name);
 	}
 }
 
@@ -193,7 +194,7 @@ static int macb_mii_probe(struct net_device *dev)
 
 	phydev = phy_find_first(bp->mii_bus);
 	if (!phydev) {
-		printk (KERN_ERR "%s: no PHY found\n", dev->name);
+		pr_err("%s: no PHY found\n", dev->name);
 		return -1;
 	}
 
@@ -206,7 +207,7 @@ static int macb_mii_probe(struct net_device *dev)
 				 PHY_INTERFACE_MODE_RMII :
 				 PHY_INTERFACE_MODE_MII);
 	if (ret) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		pr_err("%s: Could not attach to PHY\n", dev->name);
 		return ret;
 	}
 
@@ -303,7 +304,7 @@ static void macb_tx(struct macb *bp)
 
 	if (status & (MACB_BIT(UND) | MACB_BIT(TSR_RLE))) {
 		int i;
-		printk(KERN_ERR "%s: TX %s, resetting buffers\n",
+		pr_err("%s: TX %s, resetting buffers\n",
 			bp->dev->name, status & MACB_BIT(UND) ?
 			"underrun" : "retry limit exceeded");
 
@@ -574,10 +575,11 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 
 		if (status & MACB_BIT(HRESP)) {
 			/*
-			 * TODO: Reset the hardware, and maybe move the printk
-			 * to a lower-priority context as well (work queue?)
+			 * TODO: Reset the hardware, and maybe move the
+			 * pr_err to a lower-priority context as well (work
+			 * queue?)
 			 */
-			printk(KERN_ERR "%s: DMA bus error: HRESP not OK\n",
+			pr_err("%s: DMA bus error: HRESP not OK\n",
 			       dev->name);
 		}
 
@@ -950,9 +952,8 @@ static int macb_open(struct net_device *dev)
 
 	err = macb_alloc_consistent(bp);
 	if (err) {
-		printk(KERN_ERR
-		       "%s: Unable to allocate DMA memory (error %d)\n",
-		       dev->name, err);
+		pr_err("%s: Unable to allocate DMA memory (error %d)\n",
+			 dev->name, err);
 		return err;
 	}
 
@@ -1177,9 +1178,8 @@ static int __init macb_probe(struct platform_device *pdev)
 	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR
-		       "%s: Unable to request IRQ %d (error %d)\n",
-		       dev->name, dev->irq, err);
+		pr_err("%s: Unable to request IRQ %d (error %d)\n",
+			 dev->name, dev->irq, err);
 		goto err_out_iounmap;
 	}
 
@@ -1230,11 +1230,11 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
-	       dev->name, dev->base_addr, dev->irq, dev->dev_addr);
+	pr_info("%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
+		dev->name, dev->base_addr, dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
+	pr_info("%s: attached PHY driver [%s] "
 		"(mii_bus:phy_addr=%s, irq=%d)\n", dev->name,
 		phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
 
-- 
1.7.4

