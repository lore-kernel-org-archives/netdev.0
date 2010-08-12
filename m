From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/6 v2] au1000-eth: stylistic fixes
Date: Thu, 12 Aug 2010 10:09:54 +0200
Message-ID: <201008121009.54699.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41278 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549Ab0HLIJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 04:09:55 -0400
Received: by wyb32 with SMTP id 32so1100312wyb.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 01:09:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes the following checkpatch.pl warnings:
- spaces after tabs
- space between function and arguments
- one-line statement braces
- tabs instead of spaces

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 8b79635..b5f992a 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -13,7 +13,7 @@
  *  converted to use linux-2.6.x's PHY framework
  *
  * Author: MontaVista Software, Inc.
- *         	ppopov@mvista.com or source@mvista.com
+ *		ppopov@mvista.com or source@mvista.com
  *
  * ########################################################################
  *
@@ -160,7 +160,7 @@ static void au1000_enable_mac(struct net_device *dev, int force_reset)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	if(force_reset || (!aup->mac_enabled)) {
+	if (force_reset || (!aup->mac_enabled)) {
 		*aup->enable = MAC_EN_CLOCK_ENABLE;
 		au_sync_delay(2);
 		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
@@ -361,7 +361,7 @@ au1000_adjust_link(struct net_device *dev)
 	}
 }
 
-static int au1000_mii_probe (struct net_device *dev)
+static int au1000_mii_probe(struct net_device *dev)
 {
 	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
@@ -465,9 +465,9 @@ static struct db_dest *au1000_GetFreeDB(struct au1000_private *aup)
 	struct db_dest *pDB;
 	pDB = aup->pDBfree;
 
-	if (pDB) {
+	if (pDB)
 		aup->pDBfree = pDB->pnext;
-	}
+
 	return pDB;
 }
 
@@ -515,7 +515,7 @@ static void au1000_reset_mac(struct net_device *dev)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	au1000_reset_mac_unlocked (dev);
+	au1000_reset_mac_unlocked(dev);
 
 	spin_unlock_irqrestore(&aup->lock, flags);
 }
@@ -633,9 +633,9 @@ static int au1000_init(struct net_device *dev)
 	aup->mac->mac_addr_low = dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
 		dev->dev_addr[1]<<8 | dev->dev_addr[0];
 
-	for (i = 0; i < NUM_RX_DMA; i++) {
+	for (i = 0; i < NUM_RX_DMA; i++)
 		aup->rx_dma_ring[i]->buff_stat |= RX_DMA_ENABLE;
-	}
+
 	au_sync();
 
 	control = MAC_RX_ENABLE | MAC_TX_ENABLE;
@@ -862,7 +862,7 @@ static int au1000_close(struct net_device *dev)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	au1000_reset_mac_unlocked (dev);
+	au1000_reset_mac_unlocked(dev);
 
 	/* stop the device */
 	netif_stop_queue(dev);
@@ -910,9 +910,9 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	pDB = aup->tx_db_inuse[aup->tx_head];
 	skb_copy_from_linear_data(skb, (void *)pDB->vaddr, skb->len);
 	if (skb->len < ETH_ZLEN) {
-		for (i = skb->len; i < ETH_ZLEN; i++) {
+		for (i = skb->len; i < ETH_ZLEN; i++)
 			((char *)pDB->vaddr)[i] = 0;
-		}
+
 		ptxd->len = ETH_ZLEN;
 	} else
 		ptxd->len = skb->len;
@@ -1070,7 +1070,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto err_remap1;
 	}
 
-        /* Setup some variables for quick register address access */
+	/* Setup some variables for quick register address access */
 	aup->enable = (volatile u32 *)ioremap_nocache(macen->start, resource_size(macen));
 	if (!aup->enable) {
 		dev_err(&pdev->dev, "failed to ioremap MAC enable register\n");
@@ -1168,17 +1168,17 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		pDB = au1000_GetFreeDB(aup);
-		if (!pDB) {
+		if (!pDB)
 			goto err_out;
-		}
+
 		aup->rx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
 		aup->rx_db_inuse[i] = pDB;
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		pDB = au1000_GetFreeDB(aup);
-		if (!pDB) {
+		if (!pDB)
 			goto err_out;
-		}
+
 		aup->tx_dma_ring[i]->buff_stat = (unsigned)pDB->dma_addr;
 		aup->tx_dma_ring[i]->len = 0;
 		aup->tx_db_inuse[i] = pDB;


