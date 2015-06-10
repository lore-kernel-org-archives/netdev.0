From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] ixgbe: Add support for another X550 device.
Date: Tue,  9 Jun 2015 18:10:25 -0700
Message-ID: <1433898629-76729-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56324 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933172AbbFJBKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:52 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support for another 10baseT X550 device.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 7 +++++++
 4 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4b681c4..3bf2f3c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -133,6 +133,7 @@ static const struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550T), board_X550},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KX4), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KR), board_X550EM_x},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_10G_T), board_X550EM_x},
 	/* required last entry */
 	{0, }
 };
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 22646c3..ac6c0af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -347,6 +347,7 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	case TN1010_PHY_ID:
 		phy_type = ixgbe_phy_tn;
 		break;
+	case X550_PHY_ID:
 	case X540_PHY_ID:
 		phy_type = ixgbe_phy_aq;
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index b9eee32..b6f424f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1353,6 +1353,7 @@ struct ixgbe_thermal_sensor_data {
 #define TN1010_PHY_ID    0x00A19410
 #define TNX_FW_REV       0xB
 #define X540_PHY_ID      0x01540200
+#define X550_PHY_ID      0x01540220
 #define X557_PHY_ID      0x01540240
 #define QT2022_PHY_ID    0x0043A400
 #define ATH_PHY_ID       0x03429050
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index fee3d07..886bef5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1561,6 +1561,7 @@ static s32 ixgbe_reset_hw_X550em(struct ixgbe_hw *hw)
 	s32 status;
 	u32 ctrl = 0;
 	u32 i;
+	u32 hlreg0;
 	bool link_up = false;
 
 	/* Call adapter stop to disable Tx/Rx and clear interrupts */
@@ -1645,6 +1646,12 @@ mac_reset_top:
 	hw->mac.num_rar_entries = 128;
 	hw->mac.ops.init_rx_addrs(hw);
 
+	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_10G_T) {
+		hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
+		hlreg0 &= ~IXGBE_HLREG0_MDCSPD;
+		IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
+	}
+
 	if (hw->device_id == IXGBE_DEV_ID_X550EM_X_SFP)
 		ixgbe_setup_mux_ctl(hw);
 
-- 
2.4.2
