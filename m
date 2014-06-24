From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/6] amd-xgbe: Make defines in xgbe.h unique
Date: Tue, 24 Jun 2014 16:19:06 -0500
Message-ID: <20140624211906.20681.26436.stgit@tlendack-t1.amdoffice.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.139] ([207.46.163.139]:32807 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753954AbaFXVUC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:20:02 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to avoid conflicts with other include files, add
a prefix to the defines in xgbe.h.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |   23 +++----
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |  100 +++++++++++++++--------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   28 ++++----
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    8 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   43 ++++++------
 5 files changed, 102 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 6f1c859..a9ce56d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -131,7 +131,7 @@ static void xgbe_free_ring(struct xgbe_prv_data *pdata,
 
 	if (ring->rdata) {
 		for (i = 0; i < ring->rdesc_count; i++) {
-			rdata = GET_DESC_DATA(ring, i);
+			rdata = XGBE_GET_DESC_DATA(ring, i);
 			xgbe_unmap_skb(pdata, rdata);
 		}
 
@@ -256,7 +256,7 @@ static void xgbe_wrapper_tx_descriptor_init(struct xgbe_prv_data *pdata)
 		rdesc_dma = ring->rdesc_dma;
 
 		for (j = 0; j < ring->rdesc_count; j++) {
-			rdata = GET_DESC_DATA(ring, j);
+			rdata = XGBE_GET_DESC_DATA(ring, j);
 
 			rdata->rdesc = rdesc;
 			rdata->rdesc_dma = rdesc_dma;
@@ -298,7 +298,7 @@ static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
 		rdesc_dma = ring->rdesc_dma;
 
 		for (j = 0; j < ring->rdesc_count; j++) {
-			rdata = GET_DESC_DATA(ring, j);
+			rdata = XGBE_GET_DESC_DATA(ring, j);
 
 			rdata->rdesc = rdesc;
 			rdata->rdesc_dma = rdesc_dma;
@@ -392,7 +392,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 	if ((tso && (packet->mss != ring->tx.cur_mss)) ||
 	    (vlan && (packet->vlan_ctag != ring->tx.cur_vlan_ctag)))
 		cur_index++;
-	rdata = GET_DESC_DATA(ring, cur_index);
+	rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 
 	if (tso) {
 		DBGPR("  TSO packet\n");
@@ -413,12 +413,12 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		packet->length += packet->header_len;
 
 		cur_index++;
-		rdata = GET_DESC_DATA(ring, cur_index);
+		rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 	}
 
 	/* Map the (remainder of the) packet */
 	for (datalen = skb_headlen(skb) - offset; datalen; ) {
-		len = min_t(unsigned int, datalen, TX_MAX_BUF_SIZE);
+		len = min_t(unsigned int, datalen, XGBE_TX_MAX_BUF_SIZE);
 
 		skb_dma = dma_map_single(pdata->dev, skb->data + offset, len,
 					 DMA_TO_DEVICE);
@@ -437,7 +437,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		packet->length += len;
 
 		cur_index++;
-		rdata = GET_DESC_DATA(ring, cur_index);
+		rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
@@ -447,7 +447,8 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		offset = 0;
 
 		for (datalen = skb_frag_size(frag); datalen; ) {
-			len = min_t(unsigned int, datalen, TX_MAX_BUF_SIZE);
+			len = min_t(unsigned int, datalen,
+				    XGBE_TX_MAX_BUF_SIZE);
 
 			skb_dma = skb_frag_dma_map(pdata->dev, frag, offset,
 						   len, DMA_TO_DEVICE);
@@ -468,7 +469,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 			packet->length += len;
 
 			cur_index++;
-			rdata = GET_DESC_DATA(ring, cur_index);
+			rdata = XGBE_GET_DESC_DATA(ring, cur_index);
 		}
 	}
 
@@ -484,7 +485,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 
 err_out:
 	while (start_index < cur_index) {
-		rdata = GET_DESC_DATA(ring, start_index++);
+		rdata = XGBE_GET_DESC_DATA(ring, start_index++);
 		xgbe_unmap_skb(pdata, rdata);
 	}
 
@@ -507,7 +508,7 @@ static void xgbe_realloc_skb(struct xgbe_channel *channel)
 	      ring->rx.realloc_index);
 
 	for (i = 0; i < ring->dirty; i++) {
-		rdata = GET_DESC_DATA(ring, ring->rx.realloc_index);
+		rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index);
 
 		/* Reset rdata values */
 		xgbe_unmap_skb(pdata, rdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 002293b..864af2d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -766,7 +766,7 @@ static void xgbe_tx_desc_init(struct xgbe_channel *channel)
 
 	/* Initialze all descriptors */
 	for (i = 0; i < ring->rdesc_count; i++) {
-		rdata = GET_DESC_DATA(ring, i);
+		rdata = XGBE_GET_DESC_DATA(ring, i);
 		rdesc = rdata->rdesc;
 
 		/* Initialize Tx descriptor
@@ -791,7 +791,7 @@ static void xgbe_tx_desc_init(struct xgbe_channel *channel)
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDRLR, ring->rdesc_count - 1);
 
 	/* Update the starting address of descriptor ring */
-	rdata = GET_DESC_DATA(ring, start_index);
+	rdata = XGBE_GET_DESC_DATA(ring, start_index);
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDLR_HI,
 			  upper_32_bits(rdata->rdesc_dma));
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDLR_LO,
@@ -848,7 +848,7 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 
 	/* Initialize all descriptors */
 	for (i = 0; i < ring->rdesc_count; i++) {
-		rdata = GET_DESC_DATA(ring, i);
+		rdata = XGBE_GET_DESC_DATA(ring, i);
 		rdesc = rdata->rdesc;
 
 		/* Initialize Rx descriptor
@@ -882,14 +882,14 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDRLR, ring->rdesc_count - 1);
 
 	/* Update the starting address of descriptor ring */
-	rdata = GET_DESC_DATA(ring, start_index);
+	rdata = XGBE_GET_DESC_DATA(ring, start_index);
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDLR_HI,
 			  upper_32_bits(rdata->rdesc_dma));
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDLR_LO,
 			  lower_32_bits(rdata->rdesc_dma));
 
 	/* Update the Rx Descriptor Tail Pointer */
-	rdata = GET_DESC_DATA(ring, start_index + ring->rdesc_count - 1);
+	rdata = XGBE_GET_DESC_DATA(ring, start_index + ring->rdesc_count - 1);
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
 			  lower_32_bits(rdata->rdesc_dma));
 
@@ -933,7 +933,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 	if (tx_coalesce && !channel->tx_timer_active)
 		ring->coalesce_count = 0;
 
-	rdata = GET_DESC_DATA(ring, ring->cur);
+	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	rdesc = rdata->rdesc;
 
 	/* Create a context descriptor if this is a TSO packet */
@@ -977,7 +977,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 		}
 
 		ring->cur++;
-		rdata = GET_DESC_DATA(ring, ring->cur);
+		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 		rdesc = rdata->rdesc;
 	}
 
@@ -1034,7 +1034,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 
 	for (i = ring->cur - start_index + 1; i < packet->rdesc_count; i++) {
 		ring->cur++;
-		rdata = GET_DESC_DATA(ring, ring->cur);
+		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 		rdesc = rdata->rdesc;
 
 		/* Update buffer address */
@@ -1074,7 +1074,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 	wmb();
 
 	/* Set OWN bit for the first descriptor */
-	rdata = GET_DESC_DATA(ring, start_index);
+	rdata = XGBE_GET_DESC_DATA(ring, start_index);
 	rdesc = rdata->rdesc;
 	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
 
@@ -1088,7 +1088,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 	/* Issue a poll command to Tx DMA by writing address
 	 * of next immediate free descriptor */
 	ring->cur++;
-	rdata = GET_DESC_DATA(ring, ring->cur);
+	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDTR_LO,
 			  lower_32_bits(rdata->rdesc_dma));
 
@@ -1117,7 +1117,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 
 	DBGPR("-->xgbe_dev_read: cur = %d\n", ring->cur);
 
-	rdata = GET_DESC_DATA(ring, ring->cur);
+	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	rdesc = rdata->rdesc;
 
 	/* Check for data availability */
@@ -1195,7 +1195,7 @@ static void xgbe_save_interrupt_status(struct xgbe_channel *channel,
 
 	if (int_state == XGMAC_INT_STATE_SAVE) {
 		channel->saved_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
-		channel->saved_ier &= DMA_INTERRUPT_MASK;
+		channel->saved_ier &= XGBE_DMA_INTERRUPT_MASK;
 	} else {
 		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
 		dma_ch_ier |= channel->saved_ier;
@@ -1275,7 +1275,7 @@ static int xgbe_disable_int(struct xgbe_channel *channel,
 		xgbe_save_interrupt_status(channel, XGMAC_INT_STATE_SAVE);
 
 		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
-		dma_ch_ier &= ~DMA_INTERRUPT_MASK;
+		dma_ch_ier &= ~XGBE_DMA_INTERRUPT_MASK;
 		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
 		break;
 	default:
@@ -1342,23 +1342,23 @@ static void xgbe_config_dma_cache(struct xgbe_prv_data *pdata)
 	unsigned int arcache, awcache;
 
 	arcache = 0;
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRC, DMA_ARCACHE_SETTING);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRD, DMA_ARDOMAIN_SETTING);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TEC, DMA_ARCACHE_SETTING);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TED, DMA_ARDOMAIN_SETTING);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THC, DMA_ARCACHE_SETTING);
-	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THD, DMA_ARDOMAIN_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRC, XGBE_DMA_ARCACHE);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRD, XGBE_DMA_ARDOMAIN);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TEC, XGBE_DMA_ARCACHE);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TED, XGBE_DMA_ARDOMAIN);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THC, XGBE_DMA_ARCACHE);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THD, XGBE_DMA_ARDOMAIN);
 	XGMAC_IOWRITE(pdata, DMA_AXIARCR, arcache);
 
 	awcache = 0;
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWC, DMA_AWCACHE_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWD, DMA_AWDOMAIN_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPC, DMA_AWCACHE_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPD, DMA_AWDOMAIN_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHC, DMA_AWCACHE_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHD, DMA_AWDOMAIN_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDC, DMA_AWCACHE_SETTING);
-	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDD, DMA_AWDOMAIN_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWC, XGBE_DMA_AWCACHE);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWD, XGBE_DMA_AWDOMAIN);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPC, XGBE_DMA_AWCACHE);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPD, XGBE_DMA_AWDOMAIN);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHC, XGBE_DMA_AWCACHE);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHD, XGBE_DMA_AWDOMAIN);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDC, XGBE_DMA_AWCACHE);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDD, XGBE_DMA_AWDOMAIN);
 	XGMAC_IOWRITE(pdata, DMA_AXIAWCR, awcache);
 }
 
@@ -1388,66 +1388,66 @@ static unsigned int xgbe_calculate_per_queue_fifo(unsigned long fifo_size,
 	/* Calculate Tx/Rx fifo share per queue */
 	switch (fifo_size) {
 	case 0:
-		q_fifo_size = FIFO_SIZE_B(128);
+		q_fifo_size = XGBE_FIFO_SIZE_B(128);
 		break;
 	case 1:
-		q_fifo_size = FIFO_SIZE_B(256);
+		q_fifo_size = XGBE_FIFO_SIZE_B(256);
 		break;
 	case 2:
-		q_fifo_size = FIFO_SIZE_B(512);
+		q_fifo_size = XGBE_FIFO_SIZE_B(512);
 		break;
 	case 3:
-		q_fifo_size = FIFO_SIZE_KB(1);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(1);
 		break;
 	case 4:
-		q_fifo_size = FIFO_SIZE_KB(2);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(2);
 		break;
 	case 5:
-		q_fifo_size = FIFO_SIZE_KB(4);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(4);
 		break;
 	case 6:
-		q_fifo_size = FIFO_SIZE_KB(8);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(8);
 		break;
 	case 7:
-		q_fifo_size = FIFO_SIZE_KB(16);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(16);
 		break;
 	case 8:
-		q_fifo_size = FIFO_SIZE_KB(32);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(32);
 		break;
 	case 9:
-		q_fifo_size = FIFO_SIZE_KB(64);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(64);
 		break;
 	case 10:
-		q_fifo_size = FIFO_SIZE_KB(128);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(128);
 		break;
 	case 11:
-		q_fifo_size = FIFO_SIZE_KB(256);
+		q_fifo_size = XGBE_FIFO_SIZE_KB(256);
 		break;
 	}
 	q_fifo_size = q_fifo_size / queue_count;
 
 	/* Set the queue fifo size programmable value */
-	if (q_fifo_size >= FIFO_SIZE_KB(256))
+	if (q_fifo_size >= XGBE_FIFO_SIZE_KB(256))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_256K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(128))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(128))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_128K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(64))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(64))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_64K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(32))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(32))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_32K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(16))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(16))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_16K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(8))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(8))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_8K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(4))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(4))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_4K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(2))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(2))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_2K;
-	else if (q_fifo_size >= FIFO_SIZE_KB(1))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_KB(1))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_1K;
-	else if (q_fifo_size >= FIFO_SIZE_B(512))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_B(512))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_512;
-	else if (q_fifo_size >= FIFO_SIZE_B(256))
+	else if (q_fifo_size >= XGBE_FIFO_SIZE_B(256))
 		p_fifo = XGMAC_MTL_FIFO_SIZE_256;
 
 	return p_fifo;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index cfe3d93..0efb506 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -144,9 +144,10 @@ static int xgbe_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
 	}
 
 	rx_buf_size = mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
-	if (rx_buf_size < RX_MIN_BUF_SIZE)
-		rx_buf_size = RX_MIN_BUF_SIZE;
-	rx_buf_size = (rx_buf_size + RX_BUF_ALIGN - 1) & ~(RX_BUF_ALIGN - 1);
+	if (rx_buf_size < XGBE_RX_MIN_BUF_SIZE)
+		rx_buf_size = XGBE_RX_MIN_BUF_SIZE;
+	rx_buf_size = (rx_buf_size + XGBE_RX_BUF_ALIGN - 1) &
+		      ~(XGBE_RX_BUF_ALIGN - 1);
 
 	return rx_buf_size;
 }
@@ -446,7 +447,7 @@ static void xgbe_free_tx_skbuff(struct xgbe_prv_data *pdata)
 			break;
 
 		for (j = 0; j < ring->rdesc_count; j++) {
-			rdata = GET_DESC_DATA(ring, j);
+			rdata = XGBE_GET_DESC_DATA(ring, j);
 			desc_if->unmap_skb(pdata, rdata);
 		}
 	}
@@ -471,7 +472,7 @@ static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
 			break;
 
 		for (j = 0; j < ring->rdesc_count; j++) {
-			rdata = GET_DESC_DATA(ring, j);
+			rdata = XGBE_GET_DESC_DATA(ring, j);
 			desc_if->unmap_skb(pdata, rdata);
 		}
 	}
@@ -726,14 +727,14 @@ static void xgbe_packet_info(struct xgbe_ring *ring, struct sk_buff *skb,
 
 	for (len = skb_headlen(skb); len;) {
 		packet->rdesc_count++;
-		len -= min_t(unsigned int, len, TX_MAX_BUF_SIZE);
+		len -= min_t(unsigned int, len, XGBE_TX_MAX_BUF_SIZE);
 	}
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		frag = &skb_shinfo(skb)->frags[i];
 		for (len = skb_frag_size(frag); len; ) {
 			packet->rdesc_count++;
-			len -= min_t(unsigned int, len, TX_MAX_BUF_SIZE);
+			len -= min_t(unsigned int, len, XGBE_TX_MAX_BUF_SIZE);
 		}
 	}
 }
@@ -1089,8 +1090,9 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 
 	spin_lock_irqsave(&ring->lock, flags);
 
-	while ((processed < TX_DESC_MAX_PROC) && (ring->dirty < ring->cur)) {
-		rdata = GET_DESC_DATA(ring, ring->dirty);
+	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
+	       (ring->dirty < ring->cur)) {
+		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
 		rdesc = rdata->rdesc;
 
 		if (!hw_if->tx_complete(rdesc))
@@ -1109,7 +1111,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 	}
 
 	if ((ring->tx.queue_stopped == 1) &&
-	    (xgbe_tx_avail_desc(ring) > TX_DESC_MIN_FREE)) {
+	    (xgbe_tx_avail_desc(ring) > XGBE_TX_DESC_MIN_FREE)) {
 		ring->tx.queue_stopped = 0;
 		netif_wake_subqueue(netdev, channel->queue_index);
 	}
@@ -1152,7 +1154,7 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 		cur_len = 0;
 
 read_again:
-		rdata = GET_DESC_DATA(ring, ring->cur);
+		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 
 		if (hw_if->dev_read(channel))
 			break;
@@ -1244,7 +1246,7 @@ read_again:
 
 		/* Update the Rx Tail Pointer Register with address of
 		 * the last cleaned entry */
-		rdata = GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
+		rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
 		XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
 				  lower_32_bits(rdata->rdesc_dma));
 	}
@@ -1296,7 +1298,7 @@ void xgbe_dump_tx_desc(struct xgbe_ring *ring, unsigned int idx,
 	struct xgbe_ring_desc *rdesc;
 
 	while (count--) {
-		rdata = GET_DESC_DATA(ring, idx);
+		rdata = XGBE_GET_DESC_DATA(ring, idx);
 		rdesc = rdata->rdesc;
 		DBGPR("TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
 		      (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index c83584a..fefcbb6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -247,16 +247,16 @@ static int xgbe_probe(struct platform_device *pdev)
 	mutex_init(&pdata->xpcs_mutex);
 
 	/* Set and validate the number of descriptors for a ring */
-	BUILD_BUG_ON_NOT_POWER_OF_2(TX_DESC_CNT);
-	pdata->tx_desc_count = TX_DESC_CNT;
+	BUILD_BUG_ON_NOT_POWER_OF_2(XGBE_TX_DESC_CNT);
+	pdata->tx_desc_count = XGBE_TX_DESC_CNT;
 	if (pdata->tx_desc_count & (pdata->tx_desc_count - 1)) {
 		dev_err(dev, "tx descriptor count (%d) is not valid\n",
 			pdata->tx_desc_count);
 		ret = -EINVAL;
 		goto err_io;
 	}
-	BUILD_BUG_ON_NOT_POWER_OF_2(RX_DESC_CNT);
-	pdata->rx_desc_count = RX_DESC_CNT;
+	BUILD_BUG_ON_NOT_POWER_OF_2(XGBE_RX_DESC_CNT);
+	pdata->rx_desc_count = XGBE_RX_DESC_CNT;
 	if (pdata->rx_desc_count & (pdata->rx_desc_count - 1)) {
 		dev_err(dev, "rx descriptor count (%d) is not valid\n",
 			pdata->rx_desc_count);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index ab06271..f5da54c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -128,22 +128,25 @@
 #define XGBE_DRV_DESC		"AMD 10 Gigabit Ethernet Driver"
 
 /* Descriptor related defines */
-#define TX_DESC_CNT		512
-#define TX_DESC_MIN_FREE	(TX_DESC_CNT >> 3)
-#define TX_DESC_MAX_PROC	(TX_DESC_CNT >> 1)
-#define RX_DESC_CNT		512
+#define XGBE_TX_DESC_CNT	512
+#define XGBE_TX_DESC_MIN_FREE	(XGBE_TX_DESC_CNT >> 3)
+#define XGBE_TX_DESC_MAX_PROC	(XGBE_TX_DESC_CNT >> 1)
+#define XGBE_RX_DESC_CNT	512
 
-#define TX_MAX_BUF_SIZE		(0x3fff & ~(64 - 1))
+#define XGBE_TX_MAX_BUF_SIZE	(0x3fff & ~(64 - 1))
 
-#define RX_MIN_BUF_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
-#define RX_BUF_ALIGN		64
+#define XGBE_RX_MIN_BUF_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
+#define XGBE_RX_BUF_ALIGN	64
 
 #define XGBE_MAX_DMA_CHANNELS	16
-#define DMA_ARDOMAIN_SETTING	0x2
-#define DMA_ARCACHE_SETTING	0xb
-#define DMA_AWDOMAIN_SETTING	0x2
-#define DMA_AWCACHE_SETTING	0x7
-#define DMA_INTERRUPT_MASK	0x31c7
+
+/* DMA cache settings - Outer sharable, write-back, write-allocate */
+#define XGBE_DMA_ARDOMAIN	0x2
+#define XGBE_DMA_ARCACHE	0xb
+#define XGBE_DMA_AWDOMAIN	0x2
+#define XGBE_DMA_AWCACHE	0x7
+
+#define XGBE_DMA_INTERRUPT_MASK	0x31c7
 
 #define XGMAC_MIN_PACKET	60
 #define XGMAC_STD_PACKET_MTU	1500
@@ -151,10 +154,6 @@
 #define XGMAC_JUMBO_PACKET_MTU	9000
 #define XGMAC_MAX_JUMBO_PACKET	9018
 
-#define MAX_MULTICAST_LIST	14
-#define TX_FLAGS_IP_PKT		0x00000001
-#define TX_FLAGS_TCP_PKT	0x00000002
-
 /* MDIO bus phy name */
 #define XGBE_PHY_NAME		"amd_xgbe_phy"
 #define XGBE_PRTAD		0
@@ -163,18 +162,18 @@
 #define XGMAC_DRIVER_CONTEXT	1
 #define XGMAC_IOCTL_CONTEXT	2
 
-#define FIFO_SIZE_B(x)		(x)
-#define FIFO_SIZE_KB(x)		(x * 1024)
+#define XGBE_FIFO_SIZE_B(x)	(x)
+#define XGBE_FIFO_SIZE_KB(x)	(x * 1024)
 
 #define XGBE_TC_CNT		2
 
 /* Helper macro for descriptor handling
- *  Always use GET_DESC_DATA to access the descriptor data
+ *  Always use XGBE_GET_DESC_DATA to access the descriptor data
  *  since the index is free-running and needs to be and-ed
  *  with the descriptor count value of the ring to index to
  *  the proper descriptor data.
  */
-#define GET_DESC_DATA(_ring, _idx)				\
+#define XGBE_GET_DESC_DATA(_ring, _idx)				\
 	((_ring)->rdata +					\
 	 ((_idx) & ((_ring)->rdesc_count - 1)))
 
@@ -219,7 +218,7 @@ struct xgbe_ring_desc {
 
 /* Structure used to hold information related to the descriptor
  * and the packet associated with the descriptor (always use
- * use the GET_DESC_DATA macro to access this data from the ring)
+ * use the XGBE_GET_DESC_DATA macro to access this data from the ring)
  */
 struct xgbe_ring_data {
 	struct xgbe_ring_desc *rdesc;	/* Virtual address of descriptor */
@@ -250,7 +249,7 @@ struct xgbe_ring {
 	unsigned int rdesc_count;
 
 	/* Array of descriptor data corresponding the descriptor memory
-	 * (always use the GET_DESC_DATA macro to access this data)
+	 * (always use the XGBE_GET_DESC_DATA macro to access this data)
 	 */
 	struct xgbe_ring_data *rdata;
 
