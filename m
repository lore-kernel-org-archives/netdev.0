From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 7/7] drivers/net/skge.c: Use netif_printk macros
Date: Tue,  9 Feb 2010 13:49:53 -0800
Message-ID: <edbe1b719d497c0f6d02f95c6d62b05bc2b1f477.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1920 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233Ab0BIVt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:56 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skge.c |   73 ++++++++++++++++++++-------------------------------
 1 files changed, 29 insertions(+), 44 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 5ff46eb..d65138e 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -1074,13 +1074,11 @@ static void skge_link_up(struct skge_port *skge)
 	netif_carrier_on(skge->netdev);
 	netif_wake_queue(skge->netdev);
 
-	if (netif_msg_link(skge)) {
-		printk(KERN_INFO PFX
-		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",
-		       skge->netdev->name, skge->speed,
-		       skge->duplex == DUPLEX_FULL ? "full" : "half",
-		       skge_pause(skge->flow_status));
-	}
+	netif_info(skge, link, skge->netdev,
+		   "Link is up at %d Mbps, %s duplex, flow control %s\n",
+		   skge->speed,
+		   skge->duplex == DUPLEX_FULL ? "full" : "half",
+		   skge_pause(skge->flow_status));
 }
 
 static void skge_link_down(struct skge_port *skge)
@@ -1089,8 +1087,7 @@ static void skge_link_down(struct skge_port *skge)
 	netif_carrier_off(skge->netdev);
 	netif_stop_queue(skge->netdev);
 
-	if (netif_msg_link(skge))
-		printk(KERN_INFO PFX "%s: Link is down.\n", skge->netdev->name);
+	netif_info(skge, link, skge->netdev, "Link is down\n");
 }
 
 
@@ -1792,9 +1789,8 @@ static void genesis_mac_intr(struct skge_hw *hw, int port)
 	struct skge_port *skge = netdev_priv(dev);
 	u16 status = xm_read16(hw, port, XM_ISRC);
 
-	if (netif_msg_intr(skge))
-		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
-		       dev->name, status);
+	netif_printk(skge, intr, KERN_DEBUG, skge->netdev,
+		     "mac interrupt status 0x%x\n", status);
 
 	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS)) {
   		xm_link_down(hw, port);
@@ -1898,9 +1894,8 @@ static inline void bcom_phy_intr(struct skge_port *skge)
 	u16 isrc;
 
 	isrc = xm_phy_read(hw, port, PHY_BCOM_INT_STAT);
-	if (netif_msg_intr(skge))
-		printk(KERN_DEBUG PFX "%s: phy interrupt status 0x%x\n",
-		       skge->netdev->name, isrc);
+	netif_printk(skge, intr, KERN_DEBUG, skge->netdev,
+		     "phy interrupt status 0x%x\n", isrc);
 
 	if (isrc & PHY_B_IS_PSE)
 		printk(KERN_ERR PFX "%s: uncorrectable pair swap error\n",
@@ -2298,9 +2293,8 @@ static void yukon_mac_intr(struct skge_hw *hw, int port)
 	struct skge_port *skge = netdev_priv(dev);
 	u8 status = skge_read8(hw, SK_REG(port, GMAC_IRQ_SRC));
 
-	if (netif_msg_intr(skge))
-		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
-		       dev->name, status);
+	netif_printk(skge, intr, KERN_DEBUG, skge->netdev,
+		     "mac interrupt status 0x%x\n", status);
 
 	if (status & GM_IS_RX_FF_OR) {
 		++dev->stats.rx_fifo_errors;
@@ -2379,9 +2373,8 @@ static void yukon_phy_intr(struct skge_port *skge)
 	istatus = gm_phy_read(hw, port, PHY_MARV_INT_STAT);
 	phystat = gm_phy_read(hw, port, PHY_MARV_PHY_STAT);
 
-	if (netif_msg_intr(skge))
-		printk(KERN_DEBUG PFX "%s: phy interrupt status 0x%x 0x%x\n",
-		       skge->netdev->name, istatus, phystat);
+	netif_printk(skge, intr, KERN_DEBUG, skge->netdev,
+		     "phy interrupt status 0x%x 0x%x\n", istatus, phystat);
 
 	if (istatus & PHY_M_IS_AN_COMPL) {
 		if (gm_phy_read(hw, port, PHY_MARV_AUNE_LP)
@@ -2571,8 +2564,7 @@ static int skge_up(struct net_device *dev)
 	if (!is_valid_ether_addr(dev->dev_addr))
 		return -EINVAL;
 
-	if (netif_msg_ifup(skge))
-		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
+	netif_info(skge, ifup, skge->netdev, "enabling interface\n");
 
 	if (dev->mtu > RX_BUF_SIZE)
 		skge->rx_buf_size = dev->mtu + ETH_HLEN;
@@ -2670,8 +2662,7 @@ static int skge_down(struct net_device *dev)
 	if (skge->mem == NULL)
 		return 0;
 
-	if (netif_msg_ifdown(skge))
-		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+	netif_info(skge, ifdown, skge->netdev, "disabling interface\n");
 
 	netif_tx_disable(dev);
 
@@ -2825,9 +2816,9 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 
 	skge_write8(hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_START);
 
-	if (unlikely(netif_msg_tx_queued(skge)))
-		printk(KERN_DEBUG "%s: tx queued, slot %td, len %d\n",
-		       dev->name, e - skge->tx_ring.start, skb->len);
+	netif_printk(skge, tx_queued, KERN_DEBUG, skge->netdev,
+		     "tx queued, slot %td, len %d\n",
+		     e - skge->tx_ring.start, skb->len);
 
 	skge->tx_ring.to_use = e->next;
 	smp_wmb();
@@ -2858,9 +2849,8 @@ static void skge_tx_free(struct skge_port *skge, struct skge_element *e,
 			       PCI_DMA_TODEVICE);
 
 	if (control & BMU_EOF) {
-		if (unlikely(netif_msg_tx_done(skge)))
-			printk(KERN_DEBUG PFX "%s: tx done slot %td\n",
-			       skge->netdev->name, e - skge->tx_ring.start);
+		netif_printk(skge, tx_done, KERN_DEBUG, skge->netdev,
+			     "tx done slot %td\n", e - skge->tx_ring.start);
 
 		dev_kfree_skb(e->skb);
 	}
@@ -2885,8 +2875,7 @@ static void skge_tx_timeout(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 
-	if (netif_msg_timer(skge))
-		printk(KERN_DEBUG PFX "%s: tx timeout\n", dev->name);
+	netif_printk(skge, timer, KERN_DEBUG, skge->netdev, "tx timeout\n");
 
 	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_STOP);
 	skge_tx_clean(dev);
@@ -3054,10 +3043,9 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 	struct sk_buff *skb;
 	u16 len = control & BMU_BBC;
 
-	if (unlikely(netif_msg_rx_status(skge)))
-		printk(KERN_DEBUG PFX "%s: rx slot %td status 0x%x len %d\n",
-		       dev->name, e - skge->rx_ring.start,
-		       status, len);
+	netif_printk(skge, rx_status, KERN_DEBUG, skge->netdev,
+		     "rx slot %td status 0x%x len %d\n",
+		     e - skge->rx_ring.start, status, len);
 
 	if (len > skge->rx_buf_size)
 		goto error;
@@ -3111,10 +3099,9 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 	return skb;
 error:
 
-	if (netif_msg_rx_err(skge))
-		printk(KERN_DEBUG PFX "%s: rx err, slot %td control 0x%x status 0x%x\n",
-		       dev->name, e - skge->rx_ring.start,
-		       control, status);
+	netif_printk(skge, rx_err, KERN_DEBUG, skge->netdev,
+		     "rx err, slot %td control 0x%x status 0x%x\n",
+		     e - skge->rx_ring.start, control, status);
 
 	if (skge->hw->chip_id == CHIP_ID_GENESIS) {
 		if (status & (XMR_FS_RUNT|XMR_FS_LNG_ERR))
@@ -3885,9 +3872,7 @@ static void __devinit skge_show_addr(struct net_device *dev)
 {
 	const struct skge_port *skge = netdev_priv(dev);
 
-	if (netif_msg_probe(skge))
-		printk(KERN_INFO PFX "%s: addr %pM\n",
-		       dev->name, dev->dev_addr);
+	netif_info(skge, probe, skge->netdev, "addr %pM\n", dev->dev_addr);
 }
 
 static int __devinit skge_probe(struct pci_dev *pdev,
-- 
1.7.0.rc1.33.g07cf0f

