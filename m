From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] ixgbevf: Remove unused parameter
Date: Wed,  4 May 2016 09:26:48 -0700
Message-ID: <1462379208-3997-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42556 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbcEDQ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:27:16 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

ixgbevf_update_xcast_mode() is not using the netdev parameter;
removing it since it's unnecessary.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 8 ++------
 drivers/net/ethernet/intel/ixgbevf/vf.h           | 2 +-
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index ba17a61..5e348b1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1922,7 +1922,7 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	hw->mac.ops.update_xcast_mode(hw, netdev, xcast_mode);
+	hw->mac.ops.update_xcast_mode(hw, xcast_mode);
 
 	/* reprogram multicast list */
 	hw->mac.ops.update_mc_addr_list(hw, netdev);
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index f66055aa..e670d3b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -536,13 +536,11 @@ static s32 ixgbevf_hv_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 /**
  *  ixgbevf_update_xcast_mode - Update Multicast mode
  *  @hw: pointer to the HW structure
- *  @netdev: pointer to net device structure
  *  @xcast_mode: new multicast mode
  *
  *  Updates the Multicast Mode of VF.
  **/
-static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw,
-				     struct net_device *netdev, int xcast_mode)
+static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
@@ -576,9 +574,7 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw,
 /**
  * Hyper-V variant - just a stub.
  */
-static s32 ixgbevf_hv_update_xcast_mode(struct ixgbe_hw *hw,
-					struct net_device *netdev,
-					int xcast_mode)
+static s32 ixgbevf_hv_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 6770f10..2cac610 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -64,7 +64,7 @@ struct ixgbe_mac_operations {
 	s32 (*set_uc_addr)(struct ixgbe_hw *, u32, u8 *);
 	s32 (*init_rx_addrs)(struct ixgbe_hw *);
 	s32 (*update_mc_addr_list)(struct ixgbe_hw *, struct net_device *);
-	s32 (*update_xcast_mode)(struct ixgbe_hw *, struct net_device *, int);
+	s32 (*update_xcast_mode)(struct ixgbe_hw *, int);
 	s32 (*enable_mc)(struct ixgbe_hw *);
 	s32 (*disable_mc)(struct ixgbe_hw *);
 	s32 (*clear_vfta)(struct ixgbe_hw *);
-- 
2.5.5
