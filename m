From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e/i40evf: remove time_stamp member
Date: Thu, 28 May 2015 04:25:38 -0700
Message-ID: <1432812339-17129-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11036 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbbE1L0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:26:04 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver doesn't use the time_stamp member to determine if there is a
tx_hang any more. There really isn't any point to the variable at all
so just remove it. It was left over from a previous tx_hang design.

Change-ID: I4c814827e1bcb46e45118fe37acdcfa814fb62a0
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 10 ----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  7 -------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  1 -
 4 files changed, 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5fa43f7..cc82a7f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -165,9 +165,6 @@ int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 	tx_desc->cmd_type_offset_bsz =
 		build_ctob(td_cmd, 0, I40E_FDIR_MAX_RAW_PACKET_SIZE, 0);
 
-	/* set the timestamp */
-	tx_buf->time_stamp = jiffies;
-
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.
 	 */
@@ -810,10 +807,6 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 			 tx_ring->vsi->seid,
 			 tx_ring->queue_index,
 			 tx_ring->next_to_use, i);
-		dev_info(tx_ring->dev, "tx_bi[next_to_clean]\n"
-			 "  time_stamp           <%lx>\n"
-			 "  jiffies              <%lx>\n",
-			 tx_ring->tx_bi[i].time_stamp, jiffies);
 
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
@@ -2606,9 +2599,6 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 						 tx_ring->queue_index),
 			     first->bytecount);
 
-	/* set the timestamp */
-	first->time_stamp = jiffies;
-
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index ea1df3b..0dc48dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -147,7 +147,6 @@ enum i40e_dyn_idx_t {
 
 struct i40e_tx_buffer {
 	struct i40e_tx_desc *next_to_watch;
-	unsigned long time_stamp;
 	union {
 		struct sk_buff *skb;
 		void *raw_buf;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 0ac134b..ec7e220 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -322,10 +322,6 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 			 tx_ring->vsi->seid,
 			 tx_ring->queue_index,
 			 tx_ring->next_to_use, i);
-		dev_info(tx_ring->dev, "tx_bi[next_to_clean]\n"
-			 "  time_stamp           <%lx>\n"
-			 "  jiffies              <%lx>\n",
-			 tx_ring->tx_bi[i].time_stamp, jiffies);
 
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
@@ -1824,9 +1820,6 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 						 tx_ring->queue_index),
 			     first->bytecount);
 
-	/* set the timestamp */
-	first->time_stamp = jiffies;
-
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index a23f5e8..e7a34f8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -146,7 +146,6 @@ enum i40e_dyn_idx_t {
 
 struct i40e_tx_buffer {
 	struct i40e_tx_desc *next_to_watch;
-	unsigned long time_stamp;
 	union {
 		struct sk_buff *skb;
 		void *raw_buf;
-- 
2.1.0
