From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/10] ixgbe: move setting rx_pb_size into get_invariants
Date: Wed, 12 Mar 2014 19:31:26 -0700
Message-ID: <1394677890-11043-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42803 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbaCMCb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:57 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c | 3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 15506f0..650d7af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -104,6 +104,7 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 	mac->mcft_size = IXGBE_82598_MC_TBL_SIZE;
 	mac->vft_size = IXGBE_82598_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
+	mac->rx_pb_size = IXGBE_82598_RX_PB_SIZE;
 	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
 	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
@@ -205,8 +206,6 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
 	}
 
-	hw->mac.rx_pb_size = IXGBE_82598_RX_PB_SIZE;
-
 	/* set the completion timeout for interface */
 	if (ret_val == 0)
 		ixgbe_set_pcie_completion_timeout(hw);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index b96cefd..82b7462 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -270,6 +270,7 @@ static s32 ixgbe_get_invariants_82599(struct ixgbe_hw *hw)
 	mac->mcft_size = IXGBE_82599_MC_TBL_SIZE;
 	mac->vft_size = IXGBE_82599_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_82599_RAR_ENTRIES;
+	mac->rx_pb_size = IXGBE_82599_RX_PB_SIZE;
 	mac->max_rx_queues = IXGBE_82599_MAX_RX_QUEUES;
 	mac->max_tx_queues = IXGBE_82599_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
@@ -2025,7 +2026,6 @@ static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 
 	/* We need to run link autotry after the driver loads */
 	hw->mac.autotry_restart = true;
-	hw->mac.rx_pb_size = IXGBE_82599_RX_PB_SIZE;
 
 	if (ret_val == 0)
 		ret_val = ixgbe_verify_fw_version_82599(hw);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index c870f37..eed790a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -61,6 +61,7 @@ static s32 ixgbe_get_invariants_X540(struct ixgbe_hw *hw)
 	mac->mcft_size = IXGBE_X540_MC_TBL_SIZE;
 	mac->vft_size = IXGBE_X540_VFT_TBL_SIZE;
 	mac->num_rar_entries = IXGBE_X540_RAR_ENTRIES;
+	mac->rx_pb_size = IXGBE_X540_RX_PB_SIZE;
 	mac->max_rx_queues = IXGBE_X540_MAX_RX_QUEUES;
 	mac->max_tx_queues = IXGBE_X540_MAX_TX_QUEUES;
 	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_generic(hw);
@@ -187,7 +188,6 @@ static s32 ixgbe_start_hw_X540(struct ixgbe_hw *hw)
 		goto out;
 
 	ret_val = ixgbe_start_hw_gen2(hw);
-	hw->mac.rx_pb_size = IXGBE_X540_RX_PB_SIZE;
 out:
 	return ret_val;
 }
-- 
1.8.3.1
