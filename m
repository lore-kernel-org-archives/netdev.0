From: Ralf Baechle <ralf@linux-mips.org>
Subject: [DECLANCE] Fix freeing of net device
Date: Fri, 30 Jun 2006 13:56:13 +0100
Message-ID: <20060630125613.GA10454@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:58543 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932579AbWF3M4S
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 08:56:18 -0400
Received: from localhost.localdomain ([127.0.0.1]:30445 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S3686803AbWF3M4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:56:17 +0100
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Plus optical sugar.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index d3d958e..92116c2 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -704,8 +704,8 @@ static irqreturn_t lance_dma_merr_int(co
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t
-lance_interrupt(const int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t lance_interrupt(const int irq, void *dev_id,
+				   struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct lance_private *lp = netdev_priv(dev);
@@ -1254,7 +1254,7 @@ #endif
 	return 0;
 
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_out:
 	return ret;
@@ -1300,6 +1300,7 @@ static void __exit dec_lance_cleanup(voi
 	while (root_lance_dev) {
 		struct net_device *dev = root_lance_dev;
 		struct lance_private *lp = netdev_priv(dev);
+
 		unregister_netdev(dev);
 #ifdef CONFIG_TC
 		if (lp->slot >= 0)
