From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] fm10k: Move constants to the right of binary operators
Date: Tue,  5 Apr 2016 01:01:13 -0700
Message-ID: <1459843288-40623-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5422 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbcDEIBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:01:50 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The semantic patch that makes this change is available
in scripts/coccinelle/misc/compare_const_fl.cocci.

More information about semantic patching is available at
http://coccinelle.lip6.fr/

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 16 ++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   |  6 +++---
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 4de17db..d411aa5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -420,7 +420,7 @@ static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 		return;
 
 	skb_set_hash(skb, le32_to_cpu(rx_desc->d.rss),
-		     (FM10K_RSS_L4_TYPES_MASK & (1ul << rss_type)) ?
+		     ((1ul << rss_type) & FM10K_RSS_L4_TYPES_MASK) ?
 		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 }
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4eb7a6f..86700a4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -579,7 +579,7 @@ static void fm10k_configure_tx_ring(struct fm10k_intfc *interface,
 	u64 tdba = ring->dma;
 	u32 size = ring->count * sizeof(struct fm10k_tx_desc);
 	u32 txint = FM10K_INT_MAP_DISABLE;
-	u32 txdctl = FM10K_TXDCTL_ENABLE | (1 << FM10K_TXDCTL_MAX_TIME_SHIFT);
+	u32 txdctl = (1 << FM10K_TXDCTL_MAX_TIME_SHIFT) | FM10K_TXDCTL_ENABLE;
 	u8 reg_idx = ring->reg_idx;
 
 	/* disable queue to avoid issues while updating state */
@@ -903,8 +903,8 @@ static irqreturn_t fm10k_msix_mbx_vf(int __always_unused irq, void *data)
 
 	/* re-enable mailbox interrupt and indicate 20us delay */
 	fm10k_write_reg(hw, FM10K_VFITR(FM10K_MBX_VECTOR),
-			FM10K_ITR_ENABLE | (FM10K_MBX_INT_DELAY >>
-					    hw->mac.itr_scale));
+			(FM10K_MBX_INT_DELAY >> hw->mac.itr_scale) |
+			FM10K_ITR_ENABLE);
 
 	/* service upstream mailbox */
 	if (fm10k_mbx_trylock(interface)) {
@@ -1135,8 +1135,8 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 
 	/* re-enable mailbox interrupt and indicate 20us delay */
 	fm10k_write_reg(hw, FM10K_ITR(FM10K_MBX_VECTOR),
-			FM10K_ITR_ENABLE | (FM10K_MBX_INT_DELAY >>
-					    hw->mac.itr_scale));
+			(FM10K_MBX_INT_DELAY >> hw->mac.itr_scale) |
+			FM10K_ITR_ENABLE);
 
 	return IRQ_HANDLED;
 }
@@ -1253,7 +1253,7 @@ static int fm10k_mbx_request_irq_vf(struct fm10k_intfc *interface)
 	int err;
 
 	/* Use timer0 for interrupt moderation on the mailbox */
-	u32 itr = FM10K_INT_MAP_TIMER0 | entry->entry;
+	u32 itr = entry->entry | FM10K_INT_MAP_TIMER0;
 
 	/* register mailbox handlers */
 	err = hw->mbx.ops.register_handlers(&hw->mbx, vf_mbx_data);
@@ -1420,8 +1420,8 @@ static int fm10k_mbx_request_irq_pf(struct fm10k_intfc *interface)
 	int err;
 
 	/* Use timer0 for interrupt moderation on the mailbox */
-	u32 mbx_itr = FM10K_INT_MAP_TIMER0 | entry->entry;
-	u32 other_itr = FM10K_INT_MAP_IMMEDIATE | entry->entry;
+	u32 mbx_itr = entry->entry | FM10K_INT_MAP_TIMER0;
+	u32 other_itr = entry->entry | FM10K_INT_MAP_IMMEDIATE;
 
 	/* register mailbox handlers */
 	err = hw->mbx.ops.register_handlers(&hw->mbx, pf_mbx_data);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 62ccebc..34a0b03 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -711,8 +711,8 @@ static s32 fm10k_iov_assign_resources_pf(struct fm10k_hw *hw, u16 num_vfs,
 					FM10K_RXDCTL_WRITE_BACK_MIN_DELAY |
 					FM10K_RXDCTL_DROP_ON_EMPTY);
 			fm10k_write_reg(hw, FM10K_RXQCTL(vf_q_idx),
-					FM10K_RXQCTL_VF |
-					(i << FM10K_RXQCTL_VF_SHIFT));
+					(i << FM10K_RXQCTL_VF_SHIFT) |
+					FM10K_RXQCTL_VF);
 
 			/* map queue pair to VF */
 			fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), vf_q_idx);
@@ -987,7 +987,7 @@ static s32 fm10k_iov_reset_resources_pf(struct fm10k_hw *hw,
 	txqctl = ((u32)vf_vid << FM10K_TXQCTL_VID_SHIFT) |
 		 (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
 		 FM10K_TXQCTL_VF | vf_idx;
-	rxqctl = FM10K_RXQCTL_VF | (vf_idx << FM10K_RXQCTL_VF_SHIFT);
+	rxqctl = (vf_idx << FM10K_RXQCTL_VF_SHIFT) | FM10K_RXQCTL_VF;
 
 	/* stop further DMA and reset queue ownership back to VF */
 	for (i = vf_q_idx; i < (queues_per_pool + vf_q_idx); i++) {
-- 
2.5.5
