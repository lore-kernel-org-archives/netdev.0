From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/5] net: bcmgenet: re-align multiple lines correctly
Date: Wed, 23 Jul 2014 10:42:12 -0700
Message-ID: <1406137335-1671-3-git-send-email-f.fainelli@gmail.com>
References: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36884 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbaGWRnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:43:40 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so2113438pad.41
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:43:39 -0700 (PDT)
In-Reply-To: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged a lot of "CHECK: Alignment should match open
parenthesis" checks, fix all of them to make the driver neater. While
at it fix some obvious typos and re-arrange some of the lines to avoid
going over 80 columns.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- fixes some obivous typos
- re-arrange a line in bcmgenet_update_mib_counters as recommended by Joe

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 257 ++++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   4 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  28 +--
 3 files changed, 142 insertions(+), 147 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0c7af0b2f164..0f65b4a4d4a4 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -70,13 +70,13 @@
 				TOTAL_DESC * DMA_DESC_SIZE)
 
 static inline void dmadesc_set_length_status(struct bcmgenet_priv *priv,
-						void __iomem *d, u32 value)
+					     void __iomem *d, u32 value)
 {
 	__raw_writel(value, d + DMA_DESC_LENGTH_STATUS);
 }
 
 static inline u32 dmadesc_get_length_status(struct bcmgenet_priv *priv,
-						void __iomem *d)
+					    void __iomem *d)
 {
 	return __raw_readl(d + DMA_DESC_LENGTH_STATUS);
 }
@@ -99,7 +99,7 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
 
 /* Combined address + length/status setter */
 static inline void dmadesc_set(struct bcmgenet_priv *priv,
-				void __iomem *d, dma_addr_t addr, u32 val)
+			       void __iomem *d, dma_addr_t addr, u32 val)
 {
 	dmadesc_set_length_status(priv, d, val);
 	dmadesc_set_addr(priv, d, addr);
@@ -233,7 +233,7 @@ static inline struct bcmgenet_priv *dev_to_priv(struct device *dev)
 }
 
 static inline u32 bcmgenet_tdma_readl(struct bcmgenet_priv *priv,
-					enum dma_reg r)
+				      enum dma_reg r)
 {
 	return __raw_readl(priv->base + GENET_TDMA_REG_OFF +
 			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
@@ -247,7 +247,7 @@ static inline void bcmgenet_tdma_writel(struct bcmgenet_priv *priv,
 }
 
 static inline u32 bcmgenet_rdma_readl(struct bcmgenet_priv *priv,
-					enum dma_reg r)
+				      enum dma_reg r)
 {
 	return __raw_readl(priv->base + GENET_RDMA_REG_OFF +
 			DMA_RINGS_SIZE + bcmgenet_dma_regs[r]);
@@ -324,8 +324,8 @@ static const u8 genet_dma_ring_regs_v123[] = {
 static const u8 *genet_dma_ring_regs;
 
 static inline u32 bcmgenet_tdma_ring_readl(struct bcmgenet_priv *priv,
-						unsigned int ring,
-						enum dma_ring_reg r)
+					   unsigned int ring,
+					   enum dma_ring_reg r)
 {
 	return __raw_readl(priv->base + GENET_TDMA_REG_OFF +
 			(DMA_RING_SIZE * ring) +
@@ -333,9 +333,8 @@ static inline u32 bcmgenet_tdma_ring_readl(struct bcmgenet_priv *priv,
 }
 
 static inline void bcmgenet_tdma_ring_writel(struct bcmgenet_priv *priv,
-						unsigned int ring,
-						u32 val,
-						enum dma_ring_reg r)
+					     unsigned int ring, u32 val,
+					     enum dma_ring_reg r)
 {
 	__raw_writel(val, priv->base + GENET_TDMA_REG_OFF +
 			(DMA_RING_SIZE * ring) +
@@ -343,8 +342,8 @@ static inline void bcmgenet_tdma_ring_writel(struct bcmgenet_priv *priv,
 }
 
 static inline u32 bcmgenet_rdma_ring_readl(struct bcmgenet_priv *priv,
-						unsigned int ring,
-						enum dma_ring_reg r)
+					   unsigned int ring,
+					   enum dma_ring_reg r)
 {
 	return __raw_readl(priv->base + GENET_RDMA_REG_OFF +
 			(DMA_RING_SIZE * ring) +
@@ -352,9 +351,8 @@ static inline u32 bcmgenet_rdma_ring_readl(struct bcmgenet_priv *priv,
 }
 
 static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
-						unsigned int ring,
-						u32 val,
-						enum dma_ring_reg r)
+					     unsigned int ring, u32 val,
+					     enum dma_ring_reg r)
 {
 	__raw_writel(val, priv->base + GENET_RDMA_REG_OFF +
 			(DMA_RING_SIZE * ring) +
@@ -362,7 +360,7 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 }
 
 static int bcmgenet_get_settings(struct net_device *dev,
-		struct ethtool_cmd *cmd)
+				 struct ethtool_cmd *cmd)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
@@ -376,7 +374,7 @@ static int bcmgenet_get_settings(struct net_device *dev,
 }
 
 static int bcmgenet_set_settings(struct net_device *dev,
-		struct ethtool_cmd *cmd)
+				 struct ethtool_cmd *cmd)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
@@ -449,7 +447,7 @@ static int bcmgenet_set_tx_csum(struct net_device *dev,
 }
 
 static int bcmgenet_set_features(struct net_device *dev,
-		netdev_features_t features)
+				 netdev_features_t features)
 {
 	netdev_features_t changed = features ^ dev->features;
 	netdev_features_t wanted = dev->wanted_features;
@@ -616,7 +614,7 @@ static const struct bcmgenet_stats bcmgenet_gstrings_stats[] = {
 #define BCMGENET_STATS_LEN	ARRAY_SIZE(bcmgenet_gstrings_stats)
 
 static void bcmgenet_get_drvinfo(struct net_device *dev,
-		struct ethtool_drvinfo *info)
+				 struct ethtool_drvinfo *info)
 {
 	strlcpy(info->driver, "bcmgenet", sizeof(info->driver));
 	strlcpy(info->version, "v2.0", sizeof(info->version));
@@ -634,8 +632,8 @@ static int bcmgenet_get_sset_count(struct net_device *dev, int string_set)
 	}
 }
 
-static void bcmgenet_get_strings(struct net_device *dev,
-				u32 stringset, u8 *data)
+static void bcmgenet_get_strings(struct net_device *dev, u32 stringset,
+				 u8 *data)
 {
 	int i;
 
@@ -643,8 +641,8 @@ static void bcmgenet_get_strings(struct net_device *dev,
 	case ETH_SS_STATS:
 		for (i = 0; i < BCMGENET_STATS_LEN; i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
-				bcmgenet_gstrings_stats[i].stat_string,
-				ETH_GSTRING_LEN);
+			       bcmgenet_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
 		}
 		break;
 	}
@@ -669,8 +667,8 @@ static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
 		case BCMGENET_STAT_RUNT:
 			if (s->type != BCMGENET_STAT_MIB_RX)
 				offset = BCMGENET_STAT_OFFSET;
-			val = bcmgenet_umac_readl(priv, UMAC_MIB_START +
-								j + offset);
+			val = bcmgenet_umac_readl(priv,
+						  UMAC_MIB_START + j + offset);
 			break;
 		case BCMGENET_STAT_MISC:
 			val = bcmgenet_umac_readl(priv, s->reg_offset);
@@ -687,8 +685,8 @@ static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
 }
 
 static void bcmgenet_get_ethtool_stats(struct net_device *dev,
-					struct ethtool_stats *stats,
-					u64 *data)
+				       struct ethtool_stats *stats,
+				       u64 *data)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int i;
@@ -756,7 +754,7 @@ static void bcmgenet_power_down(struct bcmgenet_priv *priv,
 }
 
 static void bcmgenet_power_up(struct bcmgenet_priv *priv,
-				enum bcmgenet_power_mode mode)
+			      enum bcmgenet_power_mode mode)
 {
 	u32 reg;
 
@@ -841,37 +839,37 @@ static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_priv *priv,
 						  struct bcmgenet_tx_ring *ring)
 {
 	bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
-			INTRL2_CPU_MASK_SET);
+				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+				 INTRL2_CPU_MASK_SET);
 }
 
 static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_priv *priv,
 						 struct bcmgenet_tx_ring *ring)
 {
 	bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
-			INTRL2_CPU_MASK_CLEAR);
+				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+				 INTRL2_CPU_MASK_CLEAR);
 }
 
 static inline void bcmgenet_tx_ring_int_enable(struct bcmgenet_priv *priv,
-						struct bcmgenet_tx_ring *ring)
+					       struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_1_writel(priv,
-			(1 << ring->index), INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
+				 INTRL2_CPU_MASK_CLEAR);
 	priv->int1_mask &= ~(1 << ring->index);
 }
 
 static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
 						struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_1_writel(priv,
-			(1 << ring->index), INTRL2_CPU_MASK_SET);
+	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
+				 INTRL2_CPU_MASK_SET);
 	priv->int1_mask |= (1 << ring->index);
 }
 
 /* Unlocked version of the reclaim routine */
 static void __bcmgenet_tx_reclaim(struct net_device *dev,
-				struct bcmgenet_tx_ring *ring)
+				  struct bcmgenet_tx_ring *ring)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int last_tx_cn, last_c_index, num_tx_bds;
@@ -894,9 +892,9 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 		last_tx_cn = num_tx_bds - last_c_index + c_index;
 
 	netif_dbg(priv, tx_done, dev,
-			"%s ring=%d index=%d last_tx_cn=%d last_index=%d\n",
-			__func__, ring->index,
-			c_index, last_tx_cn, last_c_index);
+		  "%s ring=%d index=%d last_tx_cn=%d last_index=%d\n",
+		  __func__, ring->index,
+		  c_index, last_tx_cn, last_c_index);
 
 	/* Reclaim transmitted buffers */
 	while (last_tx_cn-- > 0) {
@@ -904,17 +902,17 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 		if (tx_cb_ptr->skb) {
 			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
 			dma_unmap_single(&dev->dev,
-					dma_unmap_addr(tx_cb_ptr, dma_addr),
-					tx_cb_ptr->skb->len,
-					DMA_TO_DEVICE);
+					 dma_unmap_addr(tx_cb_ptr, dma_addr),
+					 tx_cb_ptr->skb->len,
+					 DMA_TO_DEVICE);
 			bcmgenet_free_cb(tx_cb_ptr);
 		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
 			dev->stats.tx_bytes +=
 				dma_unmap_len(tx_cb_ptr, dma_len);
 			dma_unmap_page(&dev->dev,
-					dma_unmap_addr(tx_cb_ptr, dma_addr),
-					dma_unmap_len(tx_cb_ptr, dma_len),
-					DMA_TO_DEVICE);
+				       dma_unmap_addr(tx_cb_ptr, dma_addr),
+				       dma_unmap_len(tx_cb_ptr, dma_len),
+				       DMA_TO_DEVICE);
 			dma_unmap_addr_set(tx_cb_ptr, dma_addr, 0);
 		}
 		dev->stats.tx_packets++;
@@ -934,7 +932,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 }
 
 static void bcmgenet_tx_reclaim(struct net_device *dev,
-		struct bcmgenet_tx_ring *ring)
+				struct bcmgenet_tx_ring *ring)
 {
 	unsigned long flags;
 
@@ -1010,9 +1008,9 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 
 /* Transmit a SKB fragement */
 static int bcmgenet_xmit_frag(struct net_device *dev,
-				skb_frag_t *frag,
-				u16 dma_desc_flags,
-				struct bcmgenet_tx_ring *ring)
+			      skb_frag_t *frag,
+			      u16 dma_desc_flags,
+			      struct bcmgenet_tx_ring *ring)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device *kdev = &priv->pdev->dev;
@@ -1027,11 +1025,11 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 	tx_cb_ptr->skb = NULL;
 
 	mapping = skb_frag_dma_map(kdev, frag, 0,
-		skb_frag_size(frag), DMA_TO_DEVICE);
+				   skb_frag_size(frag), DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
 		netif_err(priv, tx_err, dev, "%s: Tx DMA map failed\n",
-				__func__);
+			  __func__);
 		return ret;
 	}
 
@@ -1039,8 +1037,8 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 	dma_unmap_len_set(tx_cb_ptr, dma_len, frag->size);
 
 	dmadesc_set(priv, tx_cb_ptr->bd_addr, mapping,
-			(frag->size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
-			(priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT));
+		    (frag->size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
+		    (priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT));
 
 
 	ring->free_bds -= 1;
@@ -1144,7 +1142,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (ring->free_bds <= nr_frags + 1) {
 		netif_tx_stop_queue(txq);
 		netdev_err(dev, "%s: tx ring %d full when queue %d awake\n",
-				__func__, index, ring->queue);
+			   __func__, index, ring->queue);
 		ret = NETDEV_TX_BUSY;
 		goto out;
 	}
@@ -1172,8 +1170,9 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* xmit fragment */
 	for (i = 0; i < nr_frags; i++) {
 		ret = bcmgenet_xmit_frag(dev,
-				&skb_shinfo(skb)->frags[i],
-				(i == nr_frags - 1) ? DMA_EOP : 0, ring);
+					 &skb_shinfo(skb)->frags[i],
+					 (i == nr_frags - 1) ? DMA_EOP : 0,
+					 ring);
 		if (ret) {
 			ret = NETDEV_TX_OK;
 			goto out;
@@ -1186,7 +1185,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * producer index, now write it down to the hardware
 	 */
 	bcmgenet_tdma_ring_writel(priv, ring->index,
-			ring->prod_index, TDMA_PROD_INDEX);
+				  ring->prod_index, TDMA_PROD_INDEX);
 
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1)) {
 		netif_tx_stop_queue(txq);
@@ -1200,16 +1199,14 @@ out:
 }
 
 
-static int bcmgenet_rx_refill(struct bcmgenet_priv *priv,
-				struct enet_cb *cb)
+static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
 {
 	struct device *kdev = &priv->pdev->dev;
 	struct sk_buff *skb;
 	dma_addr_t mapping;
 	int ret;
 
-	skb = netdev_alloc_skb(priv->dev,
-				priv->rx_buf_len + SKB_ALIGNMENT);
+	skb = netdev_alloc_skb(priv->dev, priv->rx_buf_len + SKB_ALIGNMENT);
 	if (!skb)
 		return -ENOMEM;
 
@@ -1217,12 +1214,12 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv,
 	WARN_ON(cb->skb != NULL);
 	cb->skb = skb;
 	mapping = dma_map_single(kdev, skb->data,
-			priv->rx_buf_len, DMA_FROM_DEVICE);
+				 priv->rx_buf_len, DMA_FROM_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
 		bcmgenet_free_cb(cb);
 		netif_err(priv, rx_err, priv->dev,
-				"%s DMA map failed\n", __func__);
+			  "%s DMA map failed\n", __func__);
 		return ret;
 	}
 
@@ -1257,8 +1254,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 	unsigned int p_index;
 	unsigned int chksum_ok = 0;
 
-	p_index = bcmgenet_rdma_ring_readl(priv,
-			DESC_INDEX, RDMA_PROD_INDEX);
+	p_index = bcmgenet_rdma_ring_readl(priv, DESC_INDEX, RDMA_PROD_INDEX);
 	p_index &= DMA_P_INDEX_MASK;
 
 	if (p_index < priv->rx_c_index)
@@ -1268,10 +1264,10 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		rxpkttoprocess = p_index - priv->rx_c_index;
 
 	netif_dbg(priv, rx_status, dev,
-		"RDMA: rxpkttoprocess=%d\n", rxpkttoprocess);
+		  "RDMA: rxpkttoprocess=%d\n", rxpkttoprocess);
 
 	while ((rxpktprocessed < rxpkttoprocess) &&
-			(rxpktprocessed < budget)) {
+	       (rxpktprocessed < budget)) {
 
 		/* Unmap the packet contents such that we can use the
 		 * RSV from the 64 bytes descriptor when enabled and save
@@ -1280,13 +1276,14 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
 		skb = cb->skb;
 		dma_unmap_single(&dev->dev, dma_unmap_addr(cb, dma_addr),
-				priv->rx_buf_len, DMA_FROM_DEVICE);
+				 priv->rx_buf_len, DMA_FROM_DEVICE);
 
 		if (!priv->desc_64b_en) {
-			dma_length_status = dmadesc_get_length_status(priv,
-							priv->rx_bds +
-							(priv->rx_read_ptr *
-							 DMA_DESC_SIZE));
+			dma_length_status =
+				dmadesc_get_length_status(priv,
+							  priv->rx_bds +
+							  (priv->rx_read_ptr *
+							   DMA_DESC_SIZE));
 		} else {
 			struct status_64 *status;
 			status = (struct status_64 *)skb->data;
@@ -1300,9 +1297,9 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		len = dma_length_status >> DMA_BUFLENGTH_SHIFT;
 
 		netif_dbg(priv, rx_status, dev,
-			"%s: p_ind=%d c_ind=%d read_ptr=%d len_stat=0x%08x\n",
-			__func__, p_index, priv->rx_c_index, priv->rx_read_ptr,
-			dma_length_status);
+			  "%s:p_ind=%d c_ind=%d read_ptr=%d len_stat=0x%08x\n",
+			  __func__, p_index, priv->rx_c_index,
+			  priv->rx_read_ptr, dma_length_status);
 
 		rxpktprocessed++;
 
@@ -1318,7 +1315,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
-					"Droping fragmented packet!\n");
+				  "dropping fragmented packet!\n");
 			dev->stats.rx_dropped++;
 			dev->stats.rx_errors++;
 			dev_kfree_skb_any(cb->skb);
@@ -1332,7 +1329,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 						DMA_RX_LG |
 						DMA_RX_RXER))) {
 			netif_err(priv, rx_status, dev, "dma_flag=0x%x\n",
-						(unsigned int)dma_flag);
+				  (unsigned int)dma_flag);
 			if (dma_flag & DMA_RX_CRC_ERROR)
 				dev->stats.rx_crc_errors++;
 			if (dma_flag & DMA_RX_OV)
@@ -1351,7 +1348,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		} /* error packet */
 
 		chksum_ok = (dma_flag & priv->dma_rx_chk_bit) &&
-				priv->desc_rxchk_en;
+			     priv->desc_rxchk_en;
 
 		skb_put(skb, len);
 		if (priv->desc_64b_en) {
@@ -1427,8 +1424,8 @@ static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 
 		if (dma_unmap_addr(cb, dma_addr)) {
 			dma_unmap_single(&priv->dev->dev,
-					dma_unmap_addr(cb, dma_addr),
-					priv->rx_buf_len, DMA_FROM_DEVICE);
+					 dma_unmap_addr(cb, dma_addr),
+					 priv->rx_buf_len, DMA_FROM_DEVICE);
 			dma_unmap_addr_set(cb, dma_addr, 0);
 		}
 
@@ -1437,8 +1434,7 @@ static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 	}
 }
 
-static void umac_enable_set(struct bcmgenet_priv *priv, u32 mask,
-				bool enable)
+static void umac_enable_set(struct bcmgenet_priv *priv, u32 mask, bool enable)
 {
 	u32 reg;
 
@@ -1514,7 +1510,8 @@ static int init_umac(struct bcmgenet_priv *priv)
 	bcmgenet_umac_writel(priv, 0, UMAC_CMD);
 	/* clear tx/rx counter */
 	bcmgenet_umac_writel(priv,
-		MIB_RESET_RX | MIB_RESET_TX | MIB_RESET_RUNT, UMAC_MIB_CTRL);
+			     MIB_RESET_RX | MIB_RESET_TX | MIB_RESET_RUNT,
+			     UMAC_MIB_CTRL);
 	bcmgenet_umac_writel(priv, 0, UMAC_MIB_CTRL);
 
 	bcmgenet_umac_writel(priv, ENET_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
@@ -1554,8 +1551,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
 		cpu_mask_clear |= UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR;
 
-	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear,
-		INTRL2_CPU_MASK_CLEAR);
+	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear, INTRL2_CPU_MASK_CLEAR);
 
 	/* Enable rx/tx engine.*/
 	dev_dbg(kdev, "done init umac\n");
@@ -1604,28 +1600,28 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 	bcmgenet_tdma_ring_writel(priv, index, 1, DMA_MBUF_DONE_THRESH);
 	/* Disable rate control for now */
 	bcmgenet_tdma_ring_writel(priv, index, flow_period_val,
-			TDMA_FLOW_PERIOD);
+				  TDMA_FLOW_PERIOD);
 	/* Unclassified traffic goes to ring 16 */
 	bcmgenet_tdma_ring_writel(priv, index,
-			((size << DMA_RING_SIZE_SHIFT) | RX_BUF_LENGTH),
-			DMA_RING_BUF_SIZE);
+				  ((size << DMA_RING_SIZE_SHIFT) |
+				   RX_BUF_LENGTH), DMA_RING_BUF_SIZE);
 
 	first_bd = write_ptr;
 
 	/* Set start and end address, read and write pointers */
 	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
-			DMA_START_ADDR);
+				  DMA_START_ADDR);
 	bcmgenet_tdma_ring_writel(priv, index, first_bd * words_per_bd,
-			TDMA_READ_PTR);
+				  TDMA_READ_PTR);
 	bcmgenet_tdma_ring_writel(priv, index, first_bd,
-			TDMA_WRITE_PTR);
+				  TDMA_WRITE_PTR);
 	bcmgenet_tdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
-			DMA_END_ADDR);
+				  DMA_END_ADDR);
 }
 
 /* Initialize a RDMA ring */
 static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
-				  unsigned int index, unsigned int size)
+				 unsigned int index, unsigned int size)
 {
 	u32 words_per_bd = WORDS_PER_BD(priv);
 	int ret;
@@ -1651,14 +1647,15 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_CONS_INDEX);
 	bcmgenet_rdma_ring_writel(priv, index,
-		((size << DMA_RING_SIZE_SHIFT) | RX_BUF_LENGTH),
-		DMA_RING_BUF_SIZE);
+				  ((size << DMA_RING_SIZE_SHIFT) |
+				   RX_BUF_LENGTH), DMA_RING_BUF_SIZE);
 	bcmgenet_rdma_ring_writel(priv, index, 0, DMA_START_ADDR);
 	bcmgenet_rdma_ring_writel(priv, index,
-		words_per_bd * size - 1, DMA_END_ADDR);
+				  words_per_bd * size - 1, DMA_END_ADDR);
 	bcmgenet_rdma_ring_writel(priv, index,
-			(DMA_FC_THRESH_LO << DMA_XOFF_THRESHOLD_SHIFT) |
-			DMA_FC_THRESH_HI, RDMA_XON_XOFF_THRESH);
+				  (DMA_FC_THRESH_LO <<
+				   DMA_XOFF_THRESHOLD_SHIFT) |
+				   DMA_FC_THRESH_HI, RDMA_XON_XOFF_THRESH);
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_READ_PTR);
 
 	return ret;
@@ -1705,8 +1702,8 @@ static void bcmgenet_init_multiq(struct net_device *dev)
 		 * (ring 16)
 		 */
 		bcmgenet_init_tx_ring(priv, i, priv->hw_params->bds_cnt,
-					i * priv->hw_params->bds_cnt,
-					(i + 1) * priv->hw_params->bds_cnt);
+				      i * priv->hw_params->bds_cnt,
+				      (i + 1) * priv->hw_params->bds_cnt);
 
 		/* Configure ring as decriptor ring and setup priority */
 		ring_cfg |= 1 << i;
@@ -1778,7 +1775,7 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
 	priv->num_tx_bds = TOTAL_DESC;
 	priv->tx_cbs = kzalloc(priv->num_tx_bds * sizeof(struct enet_cb),
-				GFP_KERNEL);
+			       GFP_KERNEL);
 	if (!priv->tx_cbs) {
 		bcmgenet_fini_dma(priv);
 		return -ENOMEM;
@@ -1789,8 +1786,9 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 
 	/* initialize special ring 16 */
 	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_DEFAULT_BD_CNT,
-			priv->hw_params->tx_queues * priv->hw_params->bds_cnt,
-			TOTAL_DESC);
+			      priv->hw_params->tx_queues *
+			      priv->hw_params->bds_cnt,
+			      TOTAL_DESC);
 
 	return 0;
 }
@@ -1811,11 +1809,11 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
 	priv->rx_c_index += work_done;
 	priv->rx_c_index &= DMA_C_INDEX_MASK;
 	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
-				priv->rx_c_index, RDMA_CONS_INDEX);
+				  priv->rx_c_index, RDMA_CONS_INDEX);
 	if (work_done < budget) {
 		napi_complete(napi);
-		bcmgenet_intrl2_0_writel(priv,
-			UMAC_IRQ_RXDMA_BDONE, INTRL2_CPU_MASK_CLEAR);
+		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
+					 INTRL2_CPU_MASK_CLEAR);
 	}
 
 	return work_done;
@@ -1838,9 +1836,9 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	/* Link UP/DOWN event */
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
-		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
+	    (priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
 		phy_mac_interrupt(priv->phydev,
-			priv->irq0_stat & UMAC_IRQ_LINK_UP);
+				  priv->irq0_stat & UMAC_IRQ_LINK_UP);
 		priv->irq0_stat &= ~(UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN);
 	}
 }
@@ -1859,7 +1857,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 	bcmgenet_intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
-		"%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
+		  "%s: IRQ=0x%x\n", __func__, priv->irq1_stat);
 	/* Check the MBDONE interrupts.
 	 * packet is done, reclaim descriptors
 	 */
@@ -1868,7 +1866,7 @@ static irqreturn_t bcmgenet_isr1(int irq, void *dev_id)
 		for (index = 0; index < 16; index++) {
 			if (priv->irq1_stat & (1 << index))
 				bcmgenet_tx_reclaim(priv->dev,
-						&priv->tx_rings[index]);
+						    &priv->tx_rings[index]);
 		}
 	}
 	return IRQ_HANDLED;
@@ -1887,7 +1885,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	bcmgenet_intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
 
 	netif_dbg(priv, intr, priv->dev,
-		"IRQ=0x%x\n", priv->irq0_stat);
+		  "IRQ=0x%x\n", priv->irq0_stat);
 
 	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
 		/* We use NAPI(software interrupt throttling, if
@@ -1895,8 +1893,8 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		 * Disable interrupt, will be enabled in the poll method.
 		 */
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			bcmgenet_intrl2_0_writel(priv,
-				UMAC_IRQ_RXDMA_BDONE, INTRL2_CPU_MASK_SET);
+			bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
+						 INTRL2_CPU_MASK_SET);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -1917,7 +1915,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	}
 
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
-		priv->irq0_stat & (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR)) {
+	    priv->irq0_stat & (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR)) {
 		priv->irq0_stat &= ~(UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
 		wake_up(&priv->wq);
 	}
@@ -1949,7 +1947,7 @@ static void bcmgenet_umac_reset(struct bcmgenet_priv *priv)
 }
 
 static void bcmgenet_set_hw_addr(struct bcmgenet_priv *priv,
-				  unsigned char *addr)
+				 unsigned char *addr)
 {
 	bcmgenet_umac_writel(priv, (addr[0] << 24) | (addr[1] << 16) |
 			(addr[2] << 8) | addr[3], UMAC_MAC0);
@@ -2070,14 +2068,14 @@ static int bcmgenet_open(struct net_device *dev)
 	bcmgenet_enable_dma(priv, dma_ctrl);
 
 	ret = request_irq(priv->irq0, bcmgenet_isr0, IRQF_SHARED,
-			dev->name, priv);
+			  dev->name, priv);
 	if (ret < 0) {
 		netdev_err(dev, "can't request IRQ %d\n", priv->irq0);
 		goto err_fini_dma;
 	}
 
 	ret = request_irq(priv->irq1, bcmgenet_isr1, IRQF_SHARED,
-				dev->name, priv);
+			  dev->name, priv);
 	if (ret < 0) {
 		netdev_err(dev, "can't request IRQ %d\n", priv->irq1);
 		goto err_irq0;
@@ -2118,8 +2116,7 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 	}
 
 	if (timeout == DMA_TIMEOUT_VAL) {
-		netdev_warn(priv->dev,
-			"Timed out while disabling TX DMA\n");
+		netdev_warn(priv->dev, "Timed out while disabling TX DMA\n");
 		ret = -ETIMEDOUT;
 	}
 
@@ -2142,9 +2139,8 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 	}
 
 	if (timeout == DMA_TIMEOUT_VAL) {
-		netdev_warn(priv->dev,
-			"Timed out while disabling RX DMA\n");
-			ret = -ETIMEDOUT;
+		netdev_warn(priv->dev, "Timed out while disabling RX DMA\n");
+		ret = -ETIMEDOUT;
 	}
 
 	return ret;
@@ -2223,12 +2219,11 @@ static inline void bcmgenet_set_mdf_addr(struct bcmgenet_priv *priv,
 {
 	u32 reg;
 
-	bcmgenet_umac_writel(priv,
-			addr[0] << 8 | addr[1], UMAC_MDF_ADDR + (*i * 4));
-	bcmgenet_umac_writel(priv,
-			addr[2] << 24 | addr[3] << 16 |
-			addr[4] << 8 | addr[5],
-			UMAC_MDF_ADDR + ((*i + 1) * 4));
+	bcmgenet_umac_writel(priv, addr[0] << 8 | addr[1],
+			     UMAC_MDF_ADDR + (*i * 4));
+	bcmgenet_umac_writel(priv, addr[2] << 24 | addr[3] << 16 |
+			     addr[4] << 8 | addr[5],
+			     UMAC_MDF_ADDR + ((*i + 1) * 4));
 	reg = bcmgenet_umac_readl(priv, UMAC_MDF_CTRL);
 	reg |= (1 << (MAX_MC_COUNT - *mc));
 	bcmgenet_umac_writel(priv, reg, UMAC_MDF_CTRL);
@@ -2425,7 +2420,7 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 
 	/* Print the GENET core version */
 	dev_info(&priv->pdev->dev, "GENET " GENET_VER_FMT,
-		major, (reg >> 16) & 0x0f, reg & 0xffff);
+		 major, (reg >> 16) & 0x0f, reg & 0xffff);
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (!(params->flags & GENET_HAS_40BITS))
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 2ef8673943de..c862d0666771 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -504,9 +504,9 @@ struct bcmgenet_tx_ring {
 	unsigned int	cb_ptr;		/* Tx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Tx ring end CB ptr */
 	void (*int_enable)(struct bcmgenet_priv *priv,
-				struct bcmgenet_tx_ring *);
+			   struct bcmgenet_tx_ring *);
 	void (*int_disable)(struct bcmgenet_priv *priv,
-				struct bcmgenet_tx_ring *);
+			    struct bcmgenet_tx_ring *);
 };
 
 /* device context */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index fb801d53c443..bdd12410fbbe 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -35,15 +35,15 @@ static int bcmgenet_mii_read(struct mii_bus *bus, int phy_id, int location)
 	u32 reg;
 
 	bcmgenet_umac_writel(priv, (MDIO_RD | (phy_id << MDIO_PMD_SHIFT) |
-			(location << MDIO_REG_SHIFT)), UMAC_MDIO_CMD);
+			     (location << MDIO_REG_SHIFT)), UMAC_MDIO_CMD);
 	/* Start MDIO transaction*/
 	reg = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
 	reg |= MDIO_START_BUSY;
 	bcmgenet_umac_writel(priv, reg, UMAC_MDIO_CMD);
 	wait_event_timeout(priv->wq,
-			!(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD)
-				& MDIO_START_BUSY),
-			HZ / 100);
+			   !(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD)
+			   & MDIO_START_BUSY),
+			   HZ / 100);
 	ret = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
 
 	if (ret & MDIO_READ_FAIL)
@@ -54,22 +54,22 @@ static int bcmgenet_mii_read(struct mii_bus *bus, int phy_id, int location)
 
 /* write a value to the MII */
 static int bcmgenet_mii_write(struct mii_bus *bus, int phy_id,
-			int location, u16 val)
+			      int location, u16 val)
 {
 	struct net_device *dev = bus->priv;
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	u32 reg;
 
 	bcmgenet_umac_writel(priv, (MDIO_WR | (phy_id << MDIO_PMD_SHIFT) |
-			(location << MDIO_REG_SHIFT) | (0xffff & val)),
-			UMAC_MDIO_CMD);
+			     (location << MDIO_REG_SHIFT) | (0xffff & val)),
+			     UMAC_MDIO_CMD);
 	reg = bcmgenet_umac_readl(priv, UMAC_MDIO_CMD);
 	reg |= MDIO_START_BUSY;
 	bcmgenet_umac_writel(priv, reg, UMAC_MDIO_CMD);
 	wait_event_timeout(priv->wq,
-			!(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD) &
-				MDIO_START_BUSY),
-			HZ / 100);
+			   !(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD) &
+			   MDIO_START_BUSY),
+			   HZ / 100);
 
 	return 0;
 }
@@ -239,7 +239,7 @@ int bcmgenet_mii_config(struct net_device *dev)
 		phy_name = "external MII";
 		phydev->supported &= PHY_BASIC_FEATURES;
 		bcmgenet_sys_writel(priv,
-				PORT_MODE_EXT_EPHY, SYS_PORT_CTRL);
+				    PORT_MODE_EXT_EPHY, SYS_PORT_CTRL);
 		break;
 
 	case PHY_INTERFACE_MODE_REVMII:
@@ -275,7 +275,7 @@ int bcmgenet_mii_config(struct net_device *dev)
 		reg |= RGMII_MODE_EN | id_mode_dis;
 		bcmgenet_ext_writel(priv, reg, EXT_RGMII_OOB_CTRL);
 		bcmgenet_sys_writel(priv,
-				PORT_MODE_EXT_GPHY, SYS_PORT_CTRL);
+				    PORT_MODE_EXT_GPHY, SYS_PORT_CTRL);
 		break;
 	default:
 		dev_err(kdev, "unknown phy mode: %d\n", priv->phy_interface);
@@ -354,7 +354,7 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 		priv->mii_bus->irq[phydev->addr] = PHY_POLL;
 
 	pr_info("attached PHY at address %d [%s]\n",
-			phydev->addr, phydev->drv->name);
+		phydev->addr, phydev->drv->name);
 
 	return 0;
 }
@@ -379,7 +379,7 @@ static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
 	bus->read = bcmgenet_mii_read;
 	bus->write = bcmgenet_mii_write;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d",
-			priv->pdev->name, priv->pdev->id);
+		 priv->pdev->name, priv->pdev->id);
 
 	bus->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bus->irq) {
-- 
1.9.1
