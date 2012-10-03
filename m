From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/5] ixgbe: add support for X540-AT1
Date: Wed,  3 Oct 2012 15:27:11 -0700
Message-ID: <1349303231-28855-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "joshua.a.hay@intel.com" <joshua.a.hay@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43800 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756711Ab2JCW1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:18 -0400
In-Reply-To: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "joshua.a.hay@intel.com" <joshua.a.hay@intel.com>

This patch adds device support for Ethernet Controller X540-AT1.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 1 +
 3 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 90e41db..dbf37e4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -70,6 +70,7 @@ static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_X540T:
+	case IXGBE_DEV_ID_X540T1:
 		return 0;
 	case IXGBE_DEV_ID_82599_T3_LOM:
 		return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c407b2f..fa3d552 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -114,6 +114,7 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_LS), board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599EN_SFP), board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF_QP), board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540T1), board_X540 },
 	/* required last entry */
 	{0, }
 };
@@ -7054,6 +7055,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 		is_wol_supported = 1;
 		break;
 	case IXGBE_DEV_ID_X540T:
+	case IXGBE_DEV_ID_X540T1:
 		/* check eeprom to see if enabled wol */
 		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
 		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 400f86a..0722f33 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -65,6 +65,7 @@
 #define IXGBE_DEV_ID_82599_LS            0x154F
 #define IXGBE_DEV_ID_X540T               0x1528
 #define IXGBE_DEV_ID_82599_SFP_SF_QP     0x154A
+#define IXGBE_DEV_ID_X540T1              0x1560
 
 /* VF Device IDs */
 #define IXGBE_DEV_ID_82599_VF           0x10ED
-- 
1.7.11.4
