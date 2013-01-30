From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] ixgbe: rename autoneg variables
Date: Wed, 30 Jan 2013 03:44:38 -0800
Message-ID: <1359546286-18179-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34241 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab3A3LpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 06:45:08 -0500
In-Reply-To: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

Renames some autoneg/speed variables to be more consistent with check_link,
get_link_capabilities, and setup_link function calls. Initializes instances
of autoneg.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 25 ++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 32 +++++++++++++-------------
 2 files changed, 28 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 1073aea..29d6aa9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -234,13 +234,13 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
  *  ixgbe_get_link_capabilities_82599 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
- *  @negotiation: true when autoneg or autotry is enabled
+ *  @autoneg: true when autoneg or autotry is enabled
  *
  *  Determines the link capabilities by reading the AUTOC register.
  **/
 static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
                                              ixgbe_link_speed *speed,
-                                             bool *negotiation)
+					     bool *autoneg)
 {
 	s32 status = 0;
 	u32 autoc = 0;
@@ -251,7 +251,7 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	    hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core0 ||
 	    hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core1) {
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = true;
+		*autoneg = true;
 		goto out;
 	}
 
@@ -268,22 +268,22 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
 	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = false;
+		*autoneg = false;
 		break;
 
 	case IXGBE_AUTOC_LMS_10G_LINK_NO_AN:
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
-		*negotiation = false;
+		*autoneg = false;
 		break;
 
 	case IXGBE_AUTOC_LMS_1G_AN:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = true;
+		*autoneg = true;
 		break;
 
 	case IXGBE_AUTOC_LMS_10G_SERIAL:
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
-		*negotiation = false;
+		*autoneg = false;
 		break;
 
 	case IXGBE_AUTOC_LMS_KX4_KX_KR:
@@ -295,7 +295,7 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
 		if (autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = true;
+		*autoneg = true;
 		break;
 
 	case IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII:
@@ -306,12 +306,12 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
 		if (autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = true;
+		*autoneg = true;
 		break;
 
 	case IXGBE_AUTOC_LMS_SGMII_1G_100M:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL | IXGBE_LINK_SPEED_100_FULL;
-		*negotiation = false;
+		*autoneg = false;
 		break;
 
 	default:
@@ -323,7 +323,7 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	if (hw->phy.multispeed_fiber) {
 		*speed |= IXGBE_LINK_SPEED_10GB_FULL |
 		          IXGBE_LINK_SPEED_1GB_FULL;
-		*negotiation = true;
+		*autoneg = true;
 	}
 
 out:
@@ -527,11 +527,10 @@ static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 	u32 esdp_reg = IXGBE_READ_REG(hw, IXGBE_ESDP);
 	u32 i = 0;
 	bool link_up = false;
-	bool negotiation;
 
 	/* Mask off requested but non-supported speeds */
 	status = hw->mac.ops.get_link_capabilities(hw, &link_speed,
-						   &negotiation);
+						   &autoneg);
 	if (status != 0)
 		return status;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ba30f2a..6c57cec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2178,10 +2178,10 @@ static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
 			return;
 
 		if (!(eicr & IXGBE_EICR_LSC) && hw->mac.ops.check_link) {
-			u32 autoneg;
+			u32 speed;
 			bool link_up = false;
 
-			hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
+			hw->mac.ops.check_link(hw, &speed, &link_up, false);
 
 			if (link_up)
 				return;
@@ -3994,25 +3994,25 @@ static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
  **/
 static int ixgbe_non_sfp_link_config(struct ixgbe_hw *hw)
 {
-	u32 autoneg;
-	bool negotiation, link_up = false;
+	u32 speed;
+	bool autoneg, link_up = false;
 	u32 ret = IXGBE_ERR_LINK_SETUP;
 
 	if (hw->mac.ops.check_link)
-		ret = hw->mac.ops.check_link(hw, &autoneg, &link_up, false);
+		ret = hw->mac.ops.check_link(hw, &speed, &link_up, false);
 
 	if (ret)
 		goto link_cfg_out;
 
-	autoneg = hw->phy.autoneg_advertised;
-	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
-		ret = hw->mac.ops.get_link_capabilities(hw, &autoneg,
-							&negotiation);
+	speed = hw->phy.autoneg_advertised;
+	if ((!speed) && (hw->mac.ops.get_link_capabilities))
+		ret = hw->mac.ops.get_link_capabilities(hw, &speed,
+							&autoneg);
 	if (ret)
 		goto link_cfg_out;
 
 	if (hw->mac.ops.setup_link)
-		ret = hw->mac.ops.setup_link(hw, autoneg, negotiation, link_up);
+		ret = hw->mac.ops.setup_link(hw, speed, autoneg, link_up);
 link_cfg_out:
 	return ret;
 }
@@ -5744,8 +5744,8 @@ sfp_out:
 static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 autoneg;
-	bool negotiation;
+	u32 speed;
+	bool autoneg = false;
 
 	if (!(adapter->flags & IXGBE_FLAG_NEED_LINK_CONFIG))
 		return;
@@ -5756,11 +5756,11 @@ static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 
 	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_CONFIG;
 
-	autoneg = hw->phy.autoneg_advertised;
-	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
-		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
+	speed = hw->phy.autoneg_advertised;
+	if ((!speed) && (hw->mac.ops.get_link_capabilities))
+		hw->mac.ops.get_link_capabilities(hw, &speed, &autoneg);
 	if (hw->mac.ops.setup_link)
-		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
+		hw->mac.ops.setup_link(hw, speed, autoneg, true);
 
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->link_check_timeout = jiffies;
-- 
1.7.11.7
