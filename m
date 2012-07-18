From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbevf: Update descriptor macros to accept pointers and drop _ADV suffix
Date: Tue, 17 Jul 2012 19:20:45 -0700
Message-ID: <1342578045-17778-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114Ab2GRCUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:53 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates the descriptor macros to accept pointers, updates the
name to drop the _ADV suffix, and include the IXGBEVF name in the macro.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   12 ++++++------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   18 +++++++++---------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index f92daca..1f13765 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -164,12 +164,12 @@ struct ixgbevf_q_vector {
 	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
 	(R)->next_to_clean - (R)->next_to_use - 1)
 
-#define IXGBE_RX_DESC_ADV(R, i)	    \
-	(&(((union ixgbe_adv_rx_desc *)((R).desc))[i]))
-#define IXGBE_TX_DESC_ADV(R, i)	    \
-	(&(((union ixgbe_adv_tx_desc *)((R).desc))[i]))
-#define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
-	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
+#define IXGBEVF_RX_DESC(R, i)	    \
+	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
+#define IXGBEVF_TX_DESC(R, i)	    \
+	(&(((union ixgbe_adv_tx_desc *)((R)->desc))[i]))
+#define IXGBEVF_TX_CTXTDESC(R, i)	    \
+	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8e022c6..c98cdf7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -195,7 +195,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
-	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+	eop_desc = IXGBEVF_TX_DESC(tx_ring, eop);
 
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
@@ -206,7 +206,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 			goto cont_loop;
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
-			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+			tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			cleaned = (i == eop);
 			skb = tx_buffer_info->skb;
@@ -235,7 +235,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 
 cont_loop:
 		eop = tx_ring->tx_buffer_info[i].next_to_watch;
-		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+		eop_desc = IXGBEVF_TX_DESC(tx_ring, eop);
 	}
 
 	tx_ring->next_to_clean = i;
@@ -339,7 +339,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 	bi = &rx_ring->rx_buffer_info[i];
 
 	while (cleaned_count--) {
-		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
 		skb = bi->skb;
 		if (!skb) {
 			skb = netdev_alloc_skb(adapter->netdev,
@@ -405,7 +405,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
-	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
@@ -432,7 +432,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		if (i == rx_ring->count)
 			i = 0;
 
-		next_rxd = IXGBE_RX_DESC_ADV(*rx_ring, i);
+		next_rxd = IXGBEVF_RX_DESC(rx_ring, i);
 		prefetch(next_rxd);
 		cleaned_count++;
 
@@ -2437,7 +2437,7 @@ static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
 		i = tx_ring->next_to_use;
 
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+		context_desc = IXGBEVF_TX_CTXTDESC(tx_ring, i);
 
 		/* VLAN MACLEN IPLEN */
 		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
@@ -2497,7 +2497,7 @@ static bool ixgbevf_tx_csum(struct ixgbevf_adapter *adapter,
 	    (tx_flags & IXGBE_TX_FLAGS_VLAN)) {
 		i = tx_ring->next_to_use;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+		context_desc = IXGBEVF_TX_CTXTDESC(tx_ring, i);
 
 		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
 			vlan_macip_lens |= (tx_flags &
@@ -2700,7 +2700,7 @@ static void ixgbevf_tx_queue(struct ixgbevf_adapter *adapter,
 	i = tx_ring->next_to_use;
 	while (count--) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+		tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
 		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
 		tx_desc->read.cmd_type_len =
 			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
-- 
1.7.10.4
