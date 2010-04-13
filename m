From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] drivers: net: use skb_headlen()
Date: Tue, 13 Apr 2010 22:48:20 +0200
Message-ID: <1271191700.16881.574.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45782 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793Ab0DMUs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 16:48:27 -0400
Received: by bwz19 with SMTP id 19so15442bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 13:48:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replaces (skb->len - skb->data_len) occurrences by skb_headlen(skb)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/atm/eni.c                  |    2 +-
 drivers/atm/he.c                   |    4 ++--
 drivers/net/3c59x.c                |    4 ++--
 drivers/net/atl1e/atl1e_main.c     |    2 +-
 drivers/net/atlx/atl1.c            |    4 ++--
 drivers/net/benet/be_main.c        |    4 ++--
 drivers/net/chelsio/sge.c          |    8 ++++----
 drivers/net/e1000/e1000_main.c     |    4 ++--
 drivers/net/e1000e/netdev.c        |    4 ++--
 drivers/net/ehea/ehea_main.c       |   10 +++++-----
 drivers/net/forcedeth.c            |    4 ++--
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/ksz884x.c              |    2 +-
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/s2io.c                 |    4 ++--
 drivers/net/tehuti.c               |    2 +-
 drivers/net/tsi108_eth.c           |    4 ++--
 17 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 719ec5a..90a5a7c 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1131,7 +1131,7 @@ DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anyway */
 			if (i == -1)
 				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
 				    skb->data,
-				    skb->len - skb->data_len);
+				    skb_headlen(skb));
 			else
 				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
 				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].page_offset,
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index c213e0d..56c2e99 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2664,8 +2664,8 @@ he_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 #ifdef USE_SCATTERGATHER
 	tpd->iovec[slot].addr = pci_map_single(he_dev->pci_dev, skb->data,
-				skb->len - skb->data_len, PCI_DMA_TODEVICE);
-	tpd->iovec[slot].len = skb->len - skb->data_len;
+				skb_headlen(skb), PCI_DMA_TODEVICE);
+	tpd->iovec[slot].len = skb_headlen(skb);
 	++slot;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 5f92fdb..9752530 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2129,8 +2129,8 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		int i;
 
 		vp->tx_ring[entry].frag[0].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data,
-										skb->len-skb->data_len, PCI_DMA_TODEVICE));
-		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb->len-skb->data_len);
+										skb_headlen(skb), PCI_DMA_TODEVICE));
+		vp->tx_ring[entry].frag[0].length = cpu_to_le32(skb_headlen(skb));
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index b6605d4..d45356f 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1679,7 +1679,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 {
 	struct atl1e_tpd_desc *use_tpd = NULL;
 	struct atl1e_tx_buffer *tx_buffer = NULL;
-	u16 buf_len = skb->len - skb->data_len;
+	u16 buf_len = skb_headsize(skb);
 	u16 map_len = 0;
 	u16 mapped_len = 0;
 	u16 hdr_len = 0;
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 0ebd820..33448a0 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2347,7 +2347,7 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	int len = skb->len;
+	int len;
 	int tso;
 	int count = 1;
 	int ret_val;
@@ -2359,7 +2359,7 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	unsigned int f;
 	unsigned int proto_hdr_len;
 
-	len -= skb->data_len;
+	len = skb_headlen(skb);
 
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 18e0a80..fa10f13 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -432,7 +432,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	map_head = txq->head;
 
 	if (skb->len > skb->data_len) {
-		int len = skb->len - skb->data_len;
+		int len = skb_headlen(skb);
 		busaddr = pci_map_single(pdev, skb->data, len,
 					 PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, busaddr))
@@ -1098,7 +1098,7 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 		cur_index = txq->tail;
 		wrb = queue_tail_node(txq);
 		unmap_tx_frag(adapter->pdev, wrb, (unmap_skb_hdr &&
-					sent_skb->len > sent_skb->data_len));
+					skb_headlen(sent_skb)));
 		unmap_skb_hdr = false;
 
 		num_wrbs++;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index a8ffc1e..f01cfdb 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1123,7 +1123,7 @@ static inline unsigned int compute_large_page_tx_descs(struct sk_buff *skb)
 
 	if (PAGE_SIZE > SGE_TX_DESC_MAX_PLEN) {
 		unsigned int nfrags = skb_shinfo(skb)->nr_frags;
-		unsigned int i, len = skb->len - skb->data_len;
+		unsigned int i, len = skb_headlen(skb);
 		while (len > SGE_TX_DESC_MAX_PLEN) {
 			count++;
 			len -= SGE_TX_DESC_MAX_PLEN;
@@ -1219,10 +1219,10 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 	ce = &q->centries[pidx];
 
 	mapping = pci_map_single(adapter->pdev, skb->data,
-				skb->len - skb->data_len, PCI_DMA_TODEVICE);
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	desc_mapping = mapping;
-	desc_len = skb->len - skb->data_len;
+	desc_len = skb_headlen(skb);
 
 	flags = F_CMD_DATAVALID | F_CMD_SOP |
 	    V_CMD_EOP(nfrags == 0 && desc_len <= SGE_TX_DESC_MAX_PLEN) |
@@ -1258,7 +1258,7 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 
 	ce->skb = NULL;
 	dma_unmap_addr_set(ce, dma_addr, mapping);
-	dma_unmap_len_set(ce, dma_len, skb->len - skb->data_len);
+	dma_unmap_len_set(ce, dma_len, skb_headlen(skb));
 
 	for (i = 0; nfrags--; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 47da5fc..974a02d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2929,7 +2929,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len - skb->data_len;
+	unsigned int len = skb_headlen(skb);
 	unsigned int nr_frags;
 	unsigned int mss;
 	int count = 0;
@@ -2980,7 +2980,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
 				}
-				len = skb->len - skb->data_len;
+				len = skb_headlen(skb);
 				break;
 			default:
 				/* do nothing */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 38390b5..214db04 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4130,7 +4130,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	unsigned int max_per_txd = E1000_MAX_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len - skb->data_len;
+	unsigned int len = skb_headsize(skb);
 	unsigned int nr_frags;
 	unsigned int mss;
 	int count = 0;
@@ -4180,7 +4180,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
-			len = skb->len - skb->data_len;
+			len = skb_headlen(skb);
 		}
 	}
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index e2d25fb..3f445ef 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1618,7 +1618,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 {
 	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
-	int skb_data_size = skb->len - skb->data_len;
+	int skb_data_size = skb_headlen(skb);
 	int headersize;
 
 	/* Packet is TCP with TSO enabled */
@@ -1629,7 +1629,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 	 */
 	headersize = ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
 
-	skb_data_size = skb->len - skb->data_len;
+	skb_data_size = skb_headlen(skb);
 
 	if (skb_data_size >= headersize) {
 		/* copy immediate data */
@@ -1651,7 +1651,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 static void write_swqe2_nonTSO(struct sk_buff *skb,
 			       struct ehea_swqe *swqe, u32 lkey)
 {
-	int skb_data_size = skb->len - skb->data_len;
+	int skb_data_size = skb_headlen(skb);
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
 
@@ -2108,8 +2108,8 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		/* first copy data from the skb->data buffer ... */
 		skb_copy_from_linear_data(skb, imm_data,
-					  skb->len - skb->data_len);
-		imm_data += skb->len - skb->data_len;
+					  skb_headlen(skb));
+		imm_data += skb_headlen(skb);
 
 		/* ... then copy data from the fragments */
 		for (i = 0; i < nfrags; i++) {
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 3267b23..6c18834 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2148,7 +2148,7 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int i;
 	u32 offset = 0;
 	u32 bcnt;
-	u32 size = skb->len-skb->data_len;
+	u32 size = skb_headlen(skb);
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
 	struct ring_desc* put_tx;
@@ -2269,7 +2269,7 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 	unsigned int i;
 	u32 offset = 0;
 	u32 bcnt;
-	u32 size = skb->len-skb->data_len;
+	u32 size = skb_headlen(skb);
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
 	struct ring_desc_ex* put_tx;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 960e985..f484161 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -604,7 +604,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		 * packets not getting split correctly
 		 */
 		if (staterr & IXGBE_RXD_STAT_LB) {
-			u32 header_fixup_len = skb->len - skb->data_len;
+			u32 header_fixup_len = skb_headlen(skb);
 			if (header_fixup_len < 14)
 				skb_push(skb, header_fixup_len);
 		}
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 4a231bd..cc0bc8a 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -4684,7 +4684,7 @@ static void send_packet(struct sk_buff *skb, struct net_device *dev)
 		int frag;
 		skb_frag_t *this_frag;
 
-		dma_buf->len = skb->len - skb->data_len;
+		dma_buf->len = skb_headlen(skb);
 
 		dma_buf->dma = pci_map_single(
 			hw_priv->pdev, skb->data, dma_buf->len,
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 958dc28..e0b47cc 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2757,7 +2757,7 @@ again:
 	}
 
 	/* map the skb for DMA */
-	len = skb->len - skb->data_len;
+	len = skb_headlen(skb);
 	idx = tx->req & tx->mask;
 	tx->info[idx].skb = skb;
 	bus = pci_map_single(mgp->pdev, skb->data, len, PCI_DMA_TODEVICE);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index bab0061..f155928 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2400,7 +2400,7 @@ static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data,
 		return NULL;
 	}
 	pci_unmap_single(nic->pdev, (dma_addr_t)txds->Buffer_Pointer,
-			 skb->len - skb->data_len, PCI_DMA_TODEVICE);
+			 skb_headlen(skb), PCI_DMA_TODEVICE);
 	frg_cnt = skb_shinfo(skb)->nr_frags;
 	if (frg_cnt) {
 		txds++;
@@ -4202,7 +4202,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		txdp->Control_2 |= TXD_VLAN_TAG(vlan_tag);
 	}
 
-	frg_len = skb->len - skb->data_len;
+	frg_len = skb_headlen(skb);
 	if (offload_type == SKB_GSO_UDP) {
 		int ufo_size;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index a38aede..93affdc 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1508,7 +1508,7 @@ bdx_tx_map_skb(struct bdx_priv *priv, struct sk_buff *skb,
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int i;
 
-	db->wptr->len = skb->len - skb->data_len;
+	db->wptr->len = skb_headsize(skb);
 	db->wptr->addr.dma = pci_map_single(priv->pdev, skb->data,
 					    db->wptr->len, PCI_DMA_TODEVICE);
 	pbl->len = CPU_CHIP_SWAP32(db->wptr->len);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 1292d23..a03730b 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -704,8 +704,8 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 
 		if (i == 0) {
 			data->txring[tx].buf0 = dma_map_single(NULL, skb->data,
-					skb->len - skb->data_len, DMA_TO_DEVICE);
-			data->txring[tx].len = skb->len - skb->data_len;
+					skb_headlen(skb), DMA_TO_DEVICE);
+			data->txring[tx].len = skb_headlen(skb);
 			misc |= TSI108_TX_SOF;
 		} else {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];


