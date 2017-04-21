From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: Add 1000Base-T device based on X550EM_X MAC
Date: Thu, 20 Apr 2017 18:50:26 -0700
Message-ID: <20170421015029.18994-9-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Paul Greenwalt <paul.greenwalt@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:63872 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034434AbdDUBvB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:51:01 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Greenwalt <paul.greenwalt@intel.com>

Add support for new 1000Base-T device based on X550EM_X MAC
type. All PHY operations are disabled as the PHY is controlled
by FW.

Signed-off-by: Paul Greenwalt <paul.greenwalt@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 45 ++++++++++++++++++++++++++-
 4 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e8cd4491f1fd..85b1afb345e3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -826,6 +826,7 @@ enum ixgbe_boards {
 	board_X540,
 	board_X550,
 	board_X550EM_x,
+	board_x550em_x_fw,
 	board_x550em_a,
 	board_x550em_a_fw,
 };
@@ -835,6 +836,7 @@ extern const struct ixgbe_info ixgbe_82599_info;
 extern const struct ixgbe_info ixgbe_X540_info;
 extern const struct ixgbe_info ixgbe_X550_info;
 extern const struct ixgbe_info ixgbe_X550EM_x_info;
+extern const struct ixgbe_info ixgbe_x550em_x_fw_info;
 extern const struct ixgbe_info ixgbe_x550em_a_info;
 extern const struct ixgbe_info ixgbe_x550em_a_fw_info;
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8a2b8e871da7..e1e0ca408d61 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -88,6 +88,7 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_X540]		= &ixgbe_X540_info,
 	[board_X550]		= &ixgbe_X550_info,
 	[board_X550EM_x]	= &ixgbe_X550EM_x_info,
+	[board_x550em_x_fw]	= &ixgbe_x550em_x_fw_info,
 	[board_x550em_a]	= &ixgbe_x550em_a_info,
 	[board_x550em_a_fw]	= &ixgbe_x550em_a_fw_info,
 };
@@ -138,6 +139,7 @@ static const struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KR), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_10G_T), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_SFP), board_X550EM_x},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_1G_T), board_x550em_x_fw},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_A_KR), board_x550em_a },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_A_KR_L), board_x550em_a },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_A_SFP_N), board_x550em_a },
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 2f06e4d9208d..9c2460c5ef1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3128,6 +3128,7 @@ enum ixgbe_phy_type {
 	ixgbe_phy_x550em_kx4,
 	ixgbe_phy_x550em_xfi,
 	ixgbe_phy_x550em_ext_t,
+	ixgbe_phy_ext_1g_t,
 	ixgbe_phy_cu_unknown,
 	ixgbe_phy_qt,
 	ixgbe_phy_xaui,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 58d3bcaca2b9..2ba024b575ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -49,6 +49,18 @@ static s32 ixgbe_get_invariants_X550_x(struct ixgbe_hw *hw)
 	return 0;
 }
 
+static s32 ixgbe_get_invariants_X550_x_fw(struct ixgbe_hw *hw)
+{
+	struct ixgbe_phy_info *phy = &hw->phy;
+
+	/* Start with X540 invariants, since so similar */
+	ixgbe_get_invariants_X540(hw);
+
+	phy->ops.set_phy_power = NULL;
+
+	return 0;
+}
+
 static s32 ixgbe_get_invariants_X550_a(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
@@ -334,9 +346,11 @@ static s32 ixgbe_identify_phy_x550em(struct ixgbe_hw *hw)
 		else
 			hw->phy.phy_semaphore_mask = IXGBE_GSSR_PHY0_SM;
 		/* Fallthrough */
-	case IXGBE_DEV_ID_X550EM_X_1G_T:
 	case IXGBE_DEV_ID_X550EM_X_10G_T:
 		return ixgbe_identify_phy_generic(hw);
+	case IXGBE_DEV_ID_X550EM_X_1G_T:
+		hw->phy.type = ixgbe_phy_ext_1g_t;
+		break;
 	case IXGBE_DEV_ID_X550EM_A_1G_T:
 	case IXGBE_DEV_ID_X550EM_A_1G_T_L:
 		hw->phy.type = ixgbe_phy_fw;
@@ -2158,6 +2172,8 @@ static void ixgbe_init_mac_link_ops_X550em(struct ixgbe_hw *hw)
 					ixgbe_set_soft_rate_select_speed;
 		break;
 	case ixgbe_media_type_copper:
+		if (hw->device_id == IXGBE_DEV_ID_X550EM_X_1G_T)
+			break;
 		mac->ops.setup_link = ixgbe_setup_mac_link_t_X550em;
 		mac->ops.setup_fc = ixgbe_setup_fc_generic;
 		mac->ops.check_link = ixgbe_check_link_t_X550em;
@@ -2238,6 +2254,7 @@ static s32 ixgbe_get_link_capabilities_X550em(struct ixgbe_hw *hw,
 			*speed = IXGBE_LINK_SPEED_1GB_FULL |
 				 IXGBE_LINK_SPEED_10GB_FULL;
 			break;
+		case ixgbe_phy_ext_1g_t:
 		case ixgbe_phy_sgmii:
 			*speed = IXGBE_LINK_SPEED_1GB_FULL;
 			break;
@@ -3185,6 +3202,11 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		phy->ops.setup_link = ixgbe_setup_fw_link;
 		phy->ops.reset = ixgbe_reset_phy_fw;
 		break;
+	case ixgbe_phy_ext_1g_t:
+		phy->ops.setup_link = NULL;
+		phy->ops.read_reg = NULL;
+		phy->ops.write_reg = NULL;
+		break;
 	default:
 		break;
 	}
@@ -3888,6 +3910,17 @@ static const struct ixgbe_phy_operations phy_ops_X550EM_x = {
 	.write_reg		= &ixgbe_write_phy_reg_generic,
 };
 
+static const struct ixgbe_phy_operations phy_ops_x550em_x_fw = {
+	X550_COMMON_PHY
+	.check_overtemp		= NULL,
+	.init			= ixgbe_init_phy_ops_X550em,
+	.identify		= ixgbe_identify_phy_x550em,
+	.read_reg		= NULL,
+	.write_reg		= NULL,
+	.read_reg_mdi		= NULL,
+	.write_reg_mdi		= NULL,
+};
+
 static const struct ixgbe_phy_operations phy_ops_x550em_a = {
 	X550_COMMON_PHY
 	.check_overtemp		= &ixgbe_tn_check_overtemp,
@@ -3950,6 +3983,16 @@ const struct ixgbe_info ixgbe_X550EM_x_info = {
 	.link_ops		= &link_ops_x550em_x,
 };
 
+const struct ixgbe_info ixgbe_x550em_x_fw_info = {
+	.mac			= ixgbe_mac_X550EM_x,
+	.get_invariants		= ixgbe_get_invariants_X550_x_fw,
+	.mac_ops		= &mac_ops_X550EM_x,
+	.eeprom_ops		= &eeprom_ops_X550EM_x,
+	.phy_ops		= &phy_ops_x550em_x_fw,
+	.mbx_ops		= &mbx_ops_generic,
+	.mvals			= ixgbe_mvals_X550EM_x,
+};
+
 const struct ixgbe_info ixgbe_x550em_a_info = {
 	.mac			= ixgbe_mac_x550em_a,
 	.get_invariants		= &ixgbe_get_invariants_X550_a,
-- 
2.12.2
