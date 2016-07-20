From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/20] fm10k: use actual hardware registers when checking for pending Tx
Date: Wed, 20 Jul 2016 15:23:45 -0700
Message-ID: <1469053438-85381-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbcGTWYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:02 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index a9ccc1e..c6a4645 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1130,9 +1130,11 @@ static u64 fm10k_get_tx_completed(struct fm10k_ring *ring)
 
 static u64 fm10k_get_tx_pending(struct fm10k_ring *ring)
 {
-	/* use SW head and tail until we have real hardware */
-	u32 head = ring->next_to_clean;
-	u32 tail = ring->next_to_use;
+	struct fm10k_intfc *interface = ring->q_vector->interface;
+	struct fm10k_hw *hw = &interface->hw;
+
+	u32 head = fm10k_read_reg(hw, FM10K_TDH(ring->reg_idx));
+	u32 tail = fm10k_read_reg(hw, FM10K_TDT(ring->reg_idx));
 
 	return ((head <= tail) ? tail : tail + ring->count) - head;
 }
-- 
2.5.5
