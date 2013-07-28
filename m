From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] e1000e: enable support for new device IDs
Date: Sun, 28 Jul 2013 04:41:14 -0700
Message-ID: <1375011676-30739-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10718 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505Ab3G1Llb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:31 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The device IDs 0x15a0 and 0x15a1 are new SKUs that contain the same MAC as
I217 and same PHY as I218.

The device IDs 0x15a2 and 0x15a3 are the same as existing I218 SKUs.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h      | 4 ++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 4 ++++
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index cee565d..b799fd9 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -90,6 +90,10 @@ struct e1000_hw;
 #define E1000_DEV_ID_PCH_LPT_I217_V		0x153B
 #define E1000_DEV_ID_PCH_LPTLP_I218_LM		0x155A
 #define E1000_DEV_ID_PCH_LPTLP_I218_V		0x1559
+#define E1000_DEV_ID_PCH_I218_LM2		0x15A0
+#define E1000_DEV_ID_PCH_I218_V2		0x15A1
+#define E1000_DEV_ID_PCH_I218_LM3		0x15A2	/* Wildcat Point PCH */
+#define E1000_DEV_ID_PCH_I218_V3		0x15A3	/* Wildcat Point PCH */
 
 #define E1000_REVISION_4	4
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index b56c61a..78d03d3 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1028,7 +1028,9 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 
 	/* Work-around I218 hang issue */
 	if ((hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_LM) ||
-	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_V)) {
+	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_V) ||
+	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_I218_LM3) ||
+	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_I218_V3)) {
 		ret_val = e1000_k1_workaround_lpt_lp(hw, link);
 		if (ret_val)
 			return ret_val;
@@ -4203,7 +4205,9 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 		u16 phy_reg, device_id = hw->adapter->pdev->device;
 
 		if ((device_id == E1000_DEV_ID_PCH_LPTLP_I218_LM) ||
-		    (device_id == E1000_DEV_ID_PCH_LPTLP_I218_V)) {
+		    (device_id == E1000_DEV_ID_PCH_LPTLP_I218_V) ||
+		    (device_id == E1000_DEV_ID_PCH_I218_LM3) ||
+		    (device_id == E1000_DEV_ID_PCH_I218_V3)) {
 			u32 fextnvm6 = er32(FEXTNVM6);
 
 			ew32(FEXTNVM6, fextnvm6 & ~E1000_FEXTNVM6_REQ_PLL_CLK);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 51b05fe..650e569 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6975,6 +6975,10 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPT_I217_V), board_pch_lpt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPTLP_I218_LM), board_pch_lpt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LPTLP_I218_V), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_I218_LM2), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_I218_V2), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_I218_LM3), board_pch_lpt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_I218_V3), board_pch_lpt },
 
 	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
-- 
1.7.11.7
