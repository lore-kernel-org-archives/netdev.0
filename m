From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] ixgbe: Drop the _ADV of descriptor macros since all ixgbe descriptors are ADV
Date: Fri, 10 Feb 2012 16:08:22 -0800
Message-ID: <1328918904-11511-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19397 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab2BKAIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:31 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It doesn't make much sense to differentiate between advanced and legacy
descriptors when the only descriptors that ixgbe uses are advanced
descriptors.  As such we can drop the _ADV suffix since all ixgbe
descriptors are automatically advanced.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   26 +++++++++++-----------
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 260e176..882a580 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -344,11 +344,11 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
 }
 
-#define IXGBE_RX_DESC_ADV(R, i)	    \
+#define IXGBE_RX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
-#define IXGBE_TX_DESC_ADV(R, i)	    \
+#define IXGBE_TX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_tx_desc *)((R)->desc))[i]))
-#define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
+#define IXGBE_TX_CTXTDESC(R, i)	    \
 	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1f31a04..1214fc1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1725,7 +1725,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 	/* initialize next to clean and descriptor values */
 	rx_ntc = rx_ring->next_to_clean;
 	tx_ntc = tx_ring->next_to_clean;
-	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, rx_ntc);
+	rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 
 	while (staterr & IXGBE_RXD_STAT_DD) {
@@ -1756,7 +1756,7 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 			tx_ntc = 0;
 
 		/* fetch next descriptor */
-		rx_desc = IXGBE_RX_DESC_ADV(rx_ring, rx_ntc);
+		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b0469dd..381d4dc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -366,7 +366,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			"leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
-			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
+			tx_desc = IXGBE_TX_DESC(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			pr_info("T [0x%03X]    %016llX %016llX %016llX"
@@ -447,7 +447,7 @@ rx_ring_summary:
 
 		for (i = 0; i < rx_ring->count; i++) {
 			rx_buffer_info = &rx_ring->rx_buffer_info[i];
-			rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
+			rx_desc = IXGBE_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 			if (staterr & IXGBE_RXD_STAT_DD) {
@@ -754,7 +754,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	u16 i = tx_ring->next_to_clean;
 
 	tx_buffer = &tx_ring->tx_buffer_info[i];
-	tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
+	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
 	for (; budget; budget--) {
 		union ixgbe_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
@@ -795,7 +795,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 				i = 0;
 
 				tx_buffer = tx_ring->tx_buffer_info;
-				tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
+				tx_desc = IXGBE_TX_DESC(tx_ring, 0);
 			}
 
 		} while (eop_desc);
@@ -812,7 +812,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	if (check_for_tx_hang(tx_ring) && ixgbe_check_tx_hang(tx_ring)) {
 		/* schedule immediate reset if we believe we hung */
 		struct ixgbe_hw *hw = &adapter->hw;
-		tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
+		tx_desc = IXGBE_TX_DESC(tx_ring, i);
 		e_err(drv, "Detected Tx Unit Hang\n"
 			"  Tx Queue             <%d>\n"
 			"  TDH, TDT             <%x>, <%x>\n"
@@ -1180,7 +1180,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 	if (!cleaned_count || !rx_ring->netdev)
 		return;
 
-	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
+	rx_desc = IXGBE_RX_DESC(rx_ring, i);
 	bi = &rx_ring->rx_buffer_info[i];
 	i -= rx_ring->count;
 
@@ -1205,7 +1205,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 		bi++;
 		i++;
 		if (unlikely(!i)) {
-			rx_desc = IXGBE_RX_DESC_ADV(rx_ring, 0);
+			rx_desc = IXGBE_RX_DESC(rx_ring, 0);
 			bi = rx_ring->rx_buffer_info;
 			i -= rx_ring->count;
 		}
@@ -1468,7 +1468,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	u16 cleaned_count = 0;
 
 	i = rx_ring->next_to_clean;
-	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
+	rx_desc = IXGBE_RX_DESC(rx_ring, i);
 
 	while (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
 		u32 upper_len = 0;
@@ -1542,7 +1542,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (i == rx_ring->count)
 			i = 0;
 
-		next_rxd = IXGBE_RX_DESC_ADV(rx_ring, i);
+		next_rxd = IXGBE_RX_DESC(rx_ring, i);
 		prefetch(next_rxd);
 		cleaned_count++;
 
@@ -6469,7 +6469,7 @@ void ixgbe_tx_ctxtdesc(struct ixgbe_ring *tx_ring, u32 vlan_macip_lens,
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	u16 i = tx_ring->next_to_use;
 
-	context_desc = IXGBE_TX_CTXTDESC_ADV(tx_ring, i);
+	context_desc = IXGBE_TX_CTXTDESC(tx_ring, i);
 
 	i++;
 	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
@@ -6702,7 +6702,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	cmd_type = ixgbe_tx_cmd_type(tx_flags);
 	olinfo_status = ixgbe_tx_olinfo_status(tx_flags, paylen);
 
-	tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
+	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
 	for (;;) {
 		while (size > IXGBE_MAX_DATA_PER_TXD) {
@@ -6717,7 +6717,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 			tx_desc++;
 			i++;
 			if (i == tx_ring->count) {
-				tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
+				tx_desc = IXGBE_TX_DESC(tx_ring, 0);
 				i = 0;
 			}
 		}
@@ -6753,7 +6753,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		tx_desc++;
 		i++;
 		if (i == tx_ring->count) {
-			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, 0);
+			tx_desc = IXGBE_TX_DESC(tx_ring, 0);
 			i = 0;
 		}
 	}
-- 
1.7.7.6
