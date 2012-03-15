From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 05/34] via-rhine: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:02 +0100
Message-ID: <de42653b37a61834aa8ebe5657111ecc4501edd2.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	David Lv <DavidLv@viatech.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51807 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752784Ab2CON7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:38 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: David Lv <DavidLv@viatech.com.cn>
---
 drivers/net/ethernet/via/via-rhine.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 39b8cf3..47b411f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -687,9 +687,12 @@ static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rhine_poll(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	rhine_interrupt(dev->irq, (void *)dev);
-	enable_irq(dev->irq);
+	struct rhine_private *rp = netdev_priv(dev);
+	const int irq = rp->pdev->irq;
+
+	disable_irq(irq);
+	rhine_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -970,7 +973,6 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	}
 #endif /* USE_MMIO */
 
-	dev->base_addr = (unsigned long)ioaddr;
 	rp->base = ioaddr;
 
 	/* Get chip registers into a sane state */
@@ -993,8 +995,6 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (!phy_id)
 		phy_id = ioread8(ioaddr + 0x6C);
 
-	dev->irq = pdev->irq;
-
 	spin_lock_init(&rp->lock);
 	mutex_init(&rp->task_lock);
 	INIT_WORK(&rp->reset_task, rhine_reset_task);
-- 
1.7.7.6
