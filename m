From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix all checkpatch errors and warnings
Date: Sun, 8 Aug 2010 22:08:44 +0200
Message-ID: <201008082208.46396.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33916 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab0HHUH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 16:07:59 -0400
Received: by wyb39 with SMTP id 39so9298789wyb.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 13:07:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a couple of errors and warnings spotted by checkpatch.pl:
- some lines were over 80 columns
- there were some whitespaces left

The call to printk is now replaced by a call to pr_info and the log-level
included in the driver version is now removed, so there are no longer false
positives on this warning.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 142c381..0a00850 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -200,7 +200,7 @@ struct r6040_private {
 	int old_duplex;
 };
 
-static char version[] __devinitdata = KERN_INFO DRV_NAME
+static char version[] __devinitdata = DRV_NAME
 	": RDC R6040 NAPI net driver,"
 	"version "DRV_VERSION " (" DRV_RELDATE ")";
 
@@ -224,7 +224,8 @@ static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 }
 
 /* Write a word data from PHY Chip */
-static void r6040_phy_write(void __iomem *ioaddr, int phy_addr, int reg, u16 val)
+static void r6040_phy_write(void __iomem *ioaddr,
+					int phy_addr, int reg, u16 val)
 {
 	int limit = 2048;
 	u16 cmd;
@@ -348,8 +349,8 @@ static int r6040_alloc_rxbufs(struct net_device *dev)
 		}
 		desc->skb_ptr = skb;
 		desc->buf = cpu_to_le32(pci_map_single(lp->pdev,
-						desc->skb_ptr->data,
-						MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
+					desc->skb_ptr->data,
+					MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
 		desc->status = DSC_OWNER_MAC;
 		desc = desc->vndescp;
 	} while (desc != lp->rx_ring);
@@ -491,12 +492,14 @@ static int r6040_close(struct net_device *dev)
 
 	/* Free Descriptor memory */
 	if (lp->rx_ring) {
-		pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
+		pci_free_consistent(pdev,
+				RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
 		lp->rx_ring = NULL;
 	}
 
 	if (lp->tx_ring) {
-		pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
+		pci_free_consistent(pdev,
+				TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
 		lp->tx_ring = NULL;
 	}
 
@@ -547,7 +550,7 @@ static int r6040_rx(struct net_device *dev, int limit)
 			}
 			goto next_descr;
 		}
-		
+
 		/* Packet successfully received */
 		new_skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 		if (!new_skb) {
@@ -556,13 +559,13 @@ static int r6040_rx(struct net_device *dev, int limit)
 		}
 		skb_ptr = descptr->skb_ptr;
 		skb_ptr->dev = priv->dev;
-		
+
 		/* Do not count the CRC */
 		skb_put(skb_ptr, descptr->len - 4);
 		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
 					MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		skb_ptr->protocol = eth_type_trans(skb_ptr, priv->dev);
-		
+
 		/* Send to upper layer */
 		netif_receive_skb(skb_ptr);
 		dev->stats.rx_packets++;
@@ -710,8 +713,10 @@ static int r6040_up(struct net_device *dev)
 		return ret;
 
 	/* improve performance (by RDC guys) */
-	r6040_phy_write(ioaddr, 30, 17, (r6040_phy_read(ioaddr, 30, 17) | 0x4000));
-	r6040_phy_write(ioaddr, 30, 17, ~((~r6040_phy_read(ioaddr, 30, 17)) | 0x2000));
+	r6040_phy_write(ioaddr, 30, 17,
+			(r6040_phy_read(ioaddr, 30, 17) | 0x4000));
+	r6040_phy_write(ioaddr, 30, 17,
+			~((~r6040_phy_read(ioaddr, 30, 17)) | 0x2000));
 	r6040_phy_write(ioaddr, 0, 19, 0x0000);
 	r6040_phy_write(ioaddr, 0, 30, 0x01F0);
 
@@ -946,7 +951,7 @@ static const struct net_device_ops r6040_netdev_ops = {
 	.ndo_set_multicast_list = r6040_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_do_ioctl		= r6040_ioctl,
 	.ndo_tx_timeout		= r6040_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1039,7 +1044,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	u16 *adrp;
 	int i;
 
-	printk("%s\n", version);
+	pr_info("%s\n", version);
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1113,7 +1118,8 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	/* Some bootloader/BIOSes do not initialize
 	 * MAC address, warn about that */
 	if (!(adrp[0] || adrp[1] || adrp[2])) {
-		netdev_warn(dev, "MAC address not initialized, generating random\n");
+		netdev_warn(dev, "MAC address not initialized, "
+					"generating random\n");
 		random_ether_addr(dev->dev_addr);
 	}
 
