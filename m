From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4] r6040: make printks consistent with DRV_NAME
Date: Wed, 7 Jan 2009 17:40:30 +0100
Message-ID: <200901071740.31046.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:25337 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbZAGQsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:48:51 -0500
Received: by mu-out-0910.google.com with SMTP id g7so3313730muf.1
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 08:48:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4] r6040: make printks consistent with DRV_NAME

This patch fixes some printks which were not prefixed
with DRV_NAME, useful when having multiple cards/drivers
on the system.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 9d2de32..3e685d7 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -200,7 +200,7 @@ struct r6040_private {
 
 static char version[] __devinitdata = KERN_INFO DRV_NAME
 	": RDC R6040 NAPI net driver,"
-	"version "DRV_VERSION " (" DRV_RELDATE ")\n";
+	"version "DRV_VERSION " (" DRV_RELDATE ")";
 
 static int phy_table[] = { PHY1_ADDR, PHY2_ADDR };
 
@@ -330,7 +330,7 @@ static int r6040_alloc_rxbufs(struct net_device *dev)
 	do {
 		skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 		if (!skb) {
-			printk(KERN_ERR "%s: failed to alloc skb for rx\n", dev->name);
+			printk(KERN_ERR DRV_NAME "%s: failed to alloc skb for rx\n", dev->name);
 			rc = -ENOMEM;
 			goto err_exit;
 		}
@@ -1063,20 +1063,20 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	/* this should always be supported */
 	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err) {
-		printk(KERN_ERR DRV_NAME "32-bit PCI DMA addresses"
+		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
 				"not supported by the card\n");
 		goto err_out;
 	}
 	err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err) {
-		printk(KERN_ERR DRV_NAME "32-bit PCI DMA addresses"
+		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
 				"not supported by the card\n");
 		goto err_out;
 	}
 
 	/* IO Size check */
 	if (pci_resource_len(pdev, 0) < io_size) {
-		printk(KERN_ERR DRV_NAME "Insufficient PCI resources, aborting\n");
+		printk(KERN_ERR DRV_NAME ": Insufficient PCI resources, aborting\n");
 		err = -EIO;
 		goto err_out;
 	}
@@ -1086,7 +1086,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct r6040_private));
 	if (!dev) {
-		printk(KERN_ERR DRV_NAME "Failed to allocate etherdev\n");
+		printk(KERN_ERR DRV_NAME ": Failed to allocate etherdev\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1102,7 +1102,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	ioaddr = pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
-		printk(KERN_ERR "ioremap failed for device %s\n",
+		printk(KERN_ERR DRV_NAME ": ioremap failed for device %s\n",
 			pci_name(pdev));
 		err = -EIO;
 		goto err_out_free_res;
