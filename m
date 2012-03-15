From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 08/34] sundance: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:05 +0100
Message-ID: <7b58b85fa2e4e46a9e5874a4c917bd4a415d7073.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51836 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750966Ab2CON7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:43 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/dlink/sundance.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index d783f4f..d7bb52a 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -522,9 +522,6 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 			cpu_to_le16(eeprom_read(ioaddr, i + EEPROM_SA_OFFSET));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	dev->base_addr = (unsigned long)ioaddr;
-	dev->irq = irq;
-
 	np = netdev_priv(dev);
 	np->base = ioaddr;
 	np->pci_dev = pdev;
@@ -828,18 +825,19 @@ static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
+	const int irq = np->pci_dev->irq;
 	unsigned long flags;
 	int i;
 
 	/* Do we need to reset the chip??? */
 
-	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i)
 		return i;
 
 	if (netif_msg_ifup(np))
-		printk(KERN_DEBUG "%s: netdev_open() irq %d.\n",
-			   dev->name, dev->irq);
+		printk(KERN_DEBUG "%s: netdev_open() irq %d\n", dev->name, irq);
+
 	init_ring(dev);
 
 	iowrite32(np->rx_ring_dma, ioaddr + RxListPtr);
@@ -1814,7 +1812,7 @@ static int netdev_close(struct net_device *dev)
 	}
 #endif /* __i386__ debugging only */
 
-	free_irq(dev->irq, dev);
+	free_irq(np->pci_dev->irq, dev);
 
 	del_timer_sync(&np->timer);
 
-- 
1.7.7.6
