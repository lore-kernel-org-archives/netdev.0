From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbevf: remove unused variable
Date: Thu,  4 Aug 2016 07:29:33 +0800
Message-ID: <1470266973-11347-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.223.11.60] ([221.223.11.60]:59696 "EHLO mail.rain.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933056AbcHCXyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 19:54:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

The variable autoneg_wait_to_complete is not used. So it is removed.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 11 +++--------
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  4 ++--
 4 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index ce221d1..f5d2ff6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -105,7 +105,7 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 	ecmd->port = -1;
 
 	hw->mac.get_link_status = true;
-	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+	hw->mac.ops.check_link(hw, &link_speed, &link_up);
 
 	if (link_up) {
 		__u32 speed = SPEED_10000;
@@ -541,7 +541,7 @@ static int ixgbevf_link_test(struct ixgbevf_adapter *adapter, u64 *data)
 	u32 link_speed = 0;
 	*data = 0;
 
-	hw->mac.ops.check_link(hw, &link_speed, &link_up, true);
+	hw->mac.ops.check_link(hw, &link_speed, &link_up);
 	if (!link_up)
 		*data = 1;
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c91c33d..c0aa6fe 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2839,7 +2839,7 @@ static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	err = hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+	err = hw->mac.ops.check_link(hw, &link_speed, &link_up);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index a52f70e..f6c862bf 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -617,14 +617,12 @@ static s32 ixgbevf_hv_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
  *  @hw: pointer to hardware structure
  *  @speed: Unused in this implementation
  *  @autoneg: Unused in this implementation
- *  @autoneg_wait_to_complete: Unused in this implementation
  *
  *  Do nothing and return success.  VF drivers are not allowed to change
  *  global settings.  Maintained for driver compatibility.
  **/
 static s32 ixgbevf_setup_mac_link_vf(struct ixgbe_hw *hw,
-				     ixgbe_link_speed speed, bool autoneg,
-				     bool autoneg_wait_to_complete)
+				     ixgbe_link_speed speed, bool autoneg)
 {
 	return 0;
 }
@@ -634,14 +632,12 @@ static s32 ixgbevf_setup_mac_link_vf(struct ixgbe_hw *hw,
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @link_up: true is link is up, false otherwise
- *  @autoneg_wait_to_complete: true when waiting for completion is needed
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
 static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 				     ixgbe_link_speed *speed,
-				     bool *link_up,
-				     bool autoneg_wait_to_complete)
+				     bool *link_up)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	struct ixgbe_mac_info *mac = &hw->mac;
@@ -722,8 +718,7 @@ out:
  */
 static s32 ixgbevf_hv_check_mac_link_vf(struct ixgbe_hw *hw,
 					ixgbe_link_speed *speed,
-					bool *link_up,
-					bool autoneg_wait_to_complete)
+					bool *link_up)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	struct ixgbe_mac_info *mac = &hw->mac;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 04d8d4e..df90478 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -54,8 +54,8 @@ struct ixgbe_mac_operations {
 	s32 (*negotiate_api_version)(struct ixgbe_hw *hw, int api);
 
 	/* Link */
-	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
-	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
+	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool);
+	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *);
 	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
 				     bool *);
 
-- 
2.7.4
