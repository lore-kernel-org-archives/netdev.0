From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/4] r6040: cleanups
Date: Wed, 28 Nov 2007 23:11:19 +0100
Message-ID: <20071128221119.GD19096@electric-eye.fr.zoreil.com>
References: <20071127204536.61bf7921.akpm@google.com> <20071127230601.fbb60024.akpm@linux-foundation.org> <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37382 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754391AbXK1WPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:15:47 -0500
Content-Disposition: inline
In-Reply-To: <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- whitespaces vs tabs
- use 80 cols
- use if_mii
- use netdev_priv
- remove useless cast to void *
- PCI device id does not need to be globally available

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r6040.c     |   33 +++++++++++++--------------------
 include/linux/pci_ids.h |    1 -
 2 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 71aa478..2334f4e 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -3,7 +3,7 @@
  *
  * Copyright (C) 2004 Sten Wang <sten.wang@rdc.com.tw>
  * Copyright (C) 2007
- * 	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
+ *	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
  *	Florian Fainelli <florian@openwrt.org>
  *
  * This program is free software; you can redistribute it and/or
@@ -60,7 +60,7 @@
 #define PHY_CAP		0x01E1	/* PHY CHIP Register 4 */
 
 /* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT  	(6000 * HZ / 1000)
+#define TX_TIMEOUT	(6000 * HZ / 1000)
 #define TIMER_WUT	(jiffies + HZ * 1)/* timer wakeup time : 1 second */
 
 /* RDC MAC I/O Size */
@@ -235,8 +235,7 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
-static void
-r6040_tx_timeout(struct net_device *dev)
+static void r6040_tx_timeout(struct net_device *dev)
 {
 	struct r6040_private *priv = netdev_priv(dev);
 
@@ -341,8 +340,7 @@ static void r6040_down(struct net_device *dev)
 	pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
 }
 
-static int
-r6040_close(struct net_device *dev)
+static int r6040_close(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 
@@ -405,7 +403,7 @@ static void r6040_set_carrier(struct mii_if_info *mii)
 static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct r6040_private *lp = netdev_priv(dev);
-	struct mii_ioctl_data *data = (struct mii_ioctl_data *) &rq->ifr_data;
+	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
 
 	if (!netif_running(dev))
@@ -574,12 +572,11 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 static void r6040_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	r6040_interrupt(dev->irq, (void *)dev);
+	r6040_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
 
-
 static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
 				 dma_addr_t desc_dma, int size)
 {
@@ -716,10 +713,9 @@ static void r6040_mac_address(struct net_device *dev)
 	iowrite16(adrp[2], ioaddr + MID_0H);
 }
 
-static int
-r6040_open(struct net_device *dev)
+static int r6040_open(struct net_device *dev)
 {
-	struct r6040_private *lp = dev->priv;
+	struct r6040_private *lp = netdev_priv(dev);
 	int ret;
 
 	/* Request IRQ and Register interrupt handler */
@@ -761,8 +757,7 @@ r6040_open(struct net_device *dev)
 	return 0;
 }
 
-static int
-r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	struct r6040_descriptor *descptr;
@@ -810,8 +805,7 @@ r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
-static void
-r6040_multicast_list(struct net_device *dev)
+static void r6040_multicast_list(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
@@ -938,7 +932,6 @@ static struct ethtool_ops netdev_ethtool_ops = {
 	.get_link		= netdev_get_link,
 };
 
-
 static int __devinit r6040_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
@@ -1075,13 +1068,13 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 
 
 static struct pci_device_id r6040_pci_tbl[] = {
-	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, PCI_DEVICE_ID_RDC_R6040) },
-	{0 }
+	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, 0x6040) },
+	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, r6040_pci_tbl);
 
 static struct pci_driver r6040_driver = {
-	.name		= "r6040",
+	.name		= DRV_NAME,
 	.id_table	= r6040_pci_tbl,
 	.probe		= r6040_init_one,
 	.remove		= __devexit_p(r6040_remove_one),
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index e148e02..290f84c 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2108,7 +2108,6 @@
 #define PCI_DEVICE_ID_HERC_UNI		0x5832
 
 #define PCI_VENDOR_ID_RDC		0x17f3
-#define PCI_DEVICE_ID_RDC_R6040		0x6040
 
 #define PCI_VENDOR_ID_SITECOM		0x182d
 #define PCI_DEVICE_ID_SITECOM_DC105V2	0x3069
-- 
1.5.3.3

