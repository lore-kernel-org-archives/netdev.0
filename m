From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: removed unused variable from setup_link_speed
Date: Thu, 31 Jan 2013 23:53:24 -0800
Message-ID: <1359705211-11342-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53335 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3BAHyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:54:05 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

Removes the autoneg parameter from the setup_link_speed functions.  These
functions do nothing with this parameter.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c   | 2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h   | 1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  | 2 +-
 6 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 4253733..dd1f0cf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -698,7 +698,7 @@ static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
 	s32 status;
 
 	/* Setup the PHY according to input speed */
-	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	status = hw->phy.ops.setup_link_speed(hw, speed,
 	                                      autoneg_wait_to_complete);
 	/* Set up MAC */
 	ixgbe_start_mac_link_82598(hw, autoneg_wait_to_complete);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 29d6aa9..6ad82cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -923,7 +923,7 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
 	s32 status;
 
 	/* Setup the PHY according to input speed */
-	status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	status = hw->phy.ops.setup_link_speed(hw, speed,
 	                                      autoneg_wait_to_complete);
 	/* Set up MAC */
 	ixgbe_start_mac_link_82599(hw, autoneg_wait_to_complete);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 71659ed..f4b2c0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -494,11 +494,9 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
  *  ixgbe_setup_phy_link_speed_generic - Sets the auto advertised capabilities
  *  @hw: pointer to hardware structure
  *  @speed: new link speed
- *  @autoneg: true if autonegotiation enabled
  **/
 s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
                                        ixgbe_link_speed speed,
-                                       bool autoneg,
                                        bool autoneg_wait_to_complete)
 {
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index cc18165..51b0a91 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -98,7 +98,6 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw);
 s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
                                        ixgbe_link_speed speed,
-                                       bool autoneg,
                                        bool autoneg_wait_to_complete);
 s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
                                                ixgbe_link_speed *speed,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 9cd8a13..85f76cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2869,8 +2869,7 @@ struct ixgbe_phy_operations {
 	s32 (*read_reg)(struct ixgbe_hw *, u32, u32, u16 *);
 	s32 (*write_reg)(struct ixgbe_hw *, u32, u32, u16);
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
-	                        bool);
+	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool);
 	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *);
 	s32 (*get_firmware_version)(struct ixgbe_hw *, u16 *);
 	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index c73b929..4ec5019 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -79,7 +79,7 @@ static s32 ixgbe_setup_mac_link_X540(struct ixgbe_hw *hw,
                                      ixgbe_link_speed speed, bool autoneg,
                                      bool autoneg_wait_to_complete)
 {
-	return hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+	return hw->phy.ops.setup_link_speed(hw, speed,
 	                                    autoneg_wait_to_complete);
 }
 
-- 
1.7.11.7
