From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 08/15] igb: Some fine tuning
Date: Fri, 24 Dec 2010 22:06:07 -0800
Message-ID: <1293257174-15498-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab0LYGHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:03 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gasparakis, Joseph <joseph.gasparakis@intel.com>

This patch does the following:

1. Changes the existing supported device id's so now DH89xxCC is not supported when EEPROM is not read.
2. Adds two more device ids for DH89xxCC in backplane mode and SFP.
3. Driver now initializes previously possibly uninitialized value in igb_reset_mdicnfg_82580().

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c |    4 +++-
 drivers/net/igb/e1000_hw.h    |    6 ++++--
 drivers/net/igb/igb_main.c    |    2 ++
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index bc183f5..50f6e96 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -134,6 +134,8 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82580_COPPER_DUAL:
 	case E1000_DEV_ID_DH89XXCC_SGMII:
 	case E1000_DEV_ID_DH89XXCC_SERDES:
+	case E1000_DEV_ID_DH89XXCC_BACKPLANE:
+	case E1000_DEV_ID_DH89XXCC_SFP:
 		mac->type = e1000_82580;
 		break;
 	case E1000_DEV_ID_I350_COPPER:
@@ -1578,7 +1580,7 @@ static s32 igb_reset_mdicnfg_82580(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 	u32 mdicnfg;
-	u16 nvm_data;
+	u16 nvm_data = 0;
 
 	if (hw->mac.type != e1000_82580)
 		goto out;
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index c0b017f..e2638af 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -54,8 +54,10 @@ struct e1000_hw;
 #define E1000_DEV_ID_82580_SERDES             0x1510
 #define E1000_DEV_ID_82580_SGMII              0x1511
 #define E1000_DEV_ID_82580_COPPER_DUAL        0x1516
-#define E1000_DEV_ID_DH89XXCC_SGMII           0x0436
-#define E1000_DEV_ID_DH89XXCC_SERDES          0x0438
+#define E1000_DEV_ID_DH89XXCC_SGMII           0x0438
+#define E1000_DEV_ID_DH89XXCC_SERDES          0x043A
+#define E1000_DEV_ID_DH89XXCC_BACKPLANE       0x043C
+#define E1000_DEV_ID_DH89XXCC_SFP             0x0440
 #define E1000_DEV_ID_I350_COPPER              0x1521
 #define E1000_DEV_ID_I350_FIBER               0x1522
 #define E1000_DEV_ID_I350_SERDES              0x1523
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c9aac7f..a364ae6 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -73,6 +73,8 @@ static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER_DUAL), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_DH89XXCC_SGMII), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_DH89XXCC_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_DH89XXCC_BACKPLANE), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_DH89XXCC_SFP), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_NS), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_NS_SERDES), board_82575 },
-- 
1.7.3.4

