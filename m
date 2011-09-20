From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] igb: Replace E1000_XX_DESC_ADV with IGB_XX_DESC
Date: Tue, 20 Sep 2011 00:11:29 -0700
Message-ID: <1316502690-25488-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17828 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302Ab1ITHLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 03:11:37 -0400
In-Reply-To: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since igb only uses advanced descriptors we might as well just use an IGB
specific define and drop the _ADV suffix for the descriptor declarations.
In addition this can be further reduced by assuming that it will be working
on pointers since that is normally how the Tx descriptors are handled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |   12 ++++++------
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    |   24 ++++++++++++------------
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index b1ca8ea..8607a1d 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -232,12 +232,12 @@ struct igb_ring {
 
 #define IGB_ADVTXD_DCMD (E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS)
 
-#define E1000_RX_DESC_ADV(R, i)	    \
-	(&(((union e1000_adv_rx_desc *)((R).desc))[i]))
-#define E1000_TX_DESC_ADV(R, i)	    \
-	(&(((union e1000_adv_tx_desc *)((R).desc))[i]))
-#define E1000_TX_CTXTDESC_ADV(R, i)	    \
-	(&(((struct e1000_adv_tx_context_desc *)((R).desc))[i]))
+#define IGB_RX_DESC(R, i)	    \
+	(&(((union e1000_adv_rx_desc *)((R)->desc))[i]))
+#define IGB_TX_DESC(R, i)	    \
+	(&(((union e1000_adv_tx_desc *)((R)->desc))[i]))
+#define IGB_TX_CTXTDESC(R, i)	    \
+	(&(((struct e1000_adv_tx_context_desc *)((R)->desc))[i]))
 
 /* igb_desc_unused - calculate if we have unused descriptors */
 static inline int igb_desc_unused(struct igb_ring *ring)
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 67eee0a..f231d82 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1586,7 +1586,7 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 	/* initialize next to clean and descriptor values */
 	rx_ntc = rx_ring->next_to_clean;
 	tx_ntc = tx_ring->next_to_clean;
-	rx_desc = E1000_RX_DESC_ADV(*rx_ring, rx_ntc);
+	rx_desc = IGB_RX_DESC(rx_ring, rx_ntc);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
 	while (staterr & E1000_RXD_STAT_DD) {
@@ -1617,7 +1617,7 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 			tx_ntc = 0;
 
 		/* fetch next descriptor */
-		rx_desc = E1000_RX_DESC_ADV(*rx_ring, rx_ntc);
+		rx_desc = IGB_RX_DESC(rx_ring, rx_ntc);
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 9a0cfd6..55d6431 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -413,7 +413,7 @@ static void igb_dump(struct igb_adapter *adapter)
 			"leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
-			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
+			tx_desc = IGB_TX_DESC(tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			printk(KERN_INFO "T [0x%03X]    %016llX %016llX %016llX"
@@ -494,7 +494,7 @@ rx_ring_summary:
 
 		for (i = 0; i < rx_ring->count; i++) {
 			buffer_info = &rx_ring->buffer_info[i];
-			rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
+			rx_desc = IGB_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 			if (staterr & E1000_RXD_STAT_DD) {
@@ -3993,7 +3993,7 @@ static inline int igb_tso(struct igb_ring *tx_ring,
 	i = tx_ring->next_to_use;
 
 	buffer_info = &tx_ring->buffer_info[i];
-	context_desc = E1000_TX_CTXTDESC_ADV(*tx_ring, i);
+	context_desc = IGB_TX_CTXTDESC(tx_ring, i);
 	/* VLAN MACLEN IPLEN */
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
 		info |= (tx_flags & IGB_TX_FLAGS_VLAN_MASK);
@@ -4048,7 +4048,7 @@ static inline bool igb_tx_csum(struct igb_ring *tx_ring,
 	    (tx_flags & IGB_TX_FLAGS_VLAN)) {
 		i = tx_ring->next_to_use;
 		buffer_info = &tx_ring->buffer_info[i];
-		context_desc = E1000_TX_CTXTDESC_ADV(*tx_ring, i);
+		context_desc = IGB_TX_CTXTDESC(tx_ring, i);
 
 		if (tx_flags & IGB_TX_FLAGS_VLAN)
 			info |= (tx_flags & IGB_TX_FLAGS_VLAN_MASK);
@@ -4238,7 +4238,7 @@ static inline void igb_tx_queue(struct igb_ring *tx_ring,
 
 	do {
 		buffer_info = &tx_ring->buffer_info[i];
-		tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
+		tx_desc = IGB_TX_DESC(tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
 		tx_desc->read.cmd_type_len =
 			cpu_to_le32(cmd_type_len | buffer_info->length);
@@ -5580,13 +5580,13 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
-	eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
+	eop_desc = IGB_TX_DESC(tx_ring, eop);
 
 	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		rmb();	/* read buffer_info after eop_desc status */
 		for (cleaned = false; !cleaned; count++) {
-			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
+			tx_desc = IGB_TX_DESC(tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
 
@@ -5605,7 +5605,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				i = 0;
 		}
 		eop = tx_ring->buffer_info[i].next_to_watch;
-		eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
+		eop_desc = IGB_TX_DESC(tx_ring, eop);
 	}
 
 	tx_ring->next_to_clean = i;
@@ -5760,7 +5760,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 	u16 cleaned_count = igb_desc_unused(rx_ring);
 	u16 i = rx_ring->next_to_clean;
 
-	rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
+	rx_desc = IGB_RX_DESC(rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
 	while (staterr & E1000_RXD_STAT_DD) {
@@ -5775,7 +5775,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		if (i == rx_ring->count)
 			i = 0;
 
-		next_rxd = E1000_RX_DESC_ADV(*rx_ring, i);
+		next_rxd = IGB_RX_DESC(rx_ring, i);
 		prefetch(next_rxd);
 
 		/*
@@ -5955,7 +5955,7 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 	struct igb_buffer *bi;
 	u16 i = rx_ring->next_to_use;
 
-	rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
+	rx_desc = IGB_RX_DESC(rx_ring, i);
 	bi = &rx_ring->buffer_info[i];
 	i -= rx_ring->count;
 
@@ -5976,7 +5976,7 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 		bi++;
 		i++;
 		if (unlikely(!i)) {
-			rx_desc = E1000_RX_DESC_ADV(*rx_ring, 0);
+			rx_desc = IGB_RX_DESC(rx_ring, 0);
 			bi = rx_ring->buffer_info;
 			i -= rx_ring->count;
 		}
-- 
1.7.6.2
