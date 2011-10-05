From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: remove instances of ixgbe_phy_aq for 82598 and 82599
Date: Wed,  5 Oct 2011 03:20:24 -0700
Message-ID: <1317810024-20846-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934301Ab1JEKUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:34 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

82598 and 82599 do not ship with this type of PHY

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c |    2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |    6 ------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  |    1 +
 3 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 56c32dc..e02e911 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -307,7 +307,6 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	switch (hw->phy.type) {
 	case ixgbe_phy_cu_unknown:
 	case ixgbe_phy_tn:
-	case ixgbe_phy_aq:
 		media_type = ixgbe_media_type_copper;
 		goto out;
 	default:
@@ -1112,7 +1111,6 @@ static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 	 * physical layer because 10GBase-T PHYs use LMS = KX4/KX */
 	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
-	case ixgbe_phy_aq:
 	case ixgbe_phy_cu_unknown:
 		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE,
 		MDIO_MMD_PMAPMD, &ext_ability);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index cdcf32a..4ae26a7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -217,10 +217,6 @@ static s32 ixgbe_init_phy_ops_82599(struct ixgbe_hw *hw)
 		phy->ops.get_firmware_version =
 		             &ixgbe_get_phy_firmware_version_tnx;
 		break;
-	case ixgbe_phy_aq:
-		phy->ops.get_firmware_version =
-			&ixgbe_get_phy_firmware_version_generic;
-		break;
 	default:
 		break;
 	}
@@ -340,7 +336,6 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	switch (hw->phy.type) {
 	case ixgbe_phy_cu_unknown:
 	case ixgbe_phy_tn:
-	case ixgbe_phy_aq:
 		media_type = ixgbe_media_type_copper;
 		goto out;
 	default:
@@ -1805,7 +1800,6 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 
 	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
-	case ixgbe_phy_aq:
 	case ixgbe_phy_cu_unknown:
 		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
 							 &ext_ability);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 96e0b20..e5101e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -870,6 +870,7 @@ static struct ixgbe_phy_operations phy_ops_X540 = {
 	.read_i2c_eeprom        = &ixgbe_read_i2c_eeprom_generic,
 	.write_i2c_eeprom       = &ixgbe_write_i2c_eeprom_generic,
 	.check_overtemp         = &ixgbe_tn_check_overtemp,
+	.get_firmware_version   = &ixgbe_get_phy_firmware_version_generic,
 };
 
 struct ixgbe_info ixgbe_X540_info = {
-- 
1.7.6.4
