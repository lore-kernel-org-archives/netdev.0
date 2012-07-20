From: Jon Mason <jdmason@kudzu.us>
Subject: [trivial PATCH resend 1/2] ixgb: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 00:02:08 -0700
Message-ID: <1342767729-17788-2-git-send-email-jdmason@kudzu.us>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64386 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab2GTHBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 03:01:52 -0400
Received: by pbbrp8 with SMTP id rp8so5694974pbb.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 00:01:51 -0700 (PDT)
In-Reply-To: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PCI_VENDOR_ID_INTEL from pci_ids.h instead of creating its own
vendor ID #define.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_hw.c   |    5 +++--
 drivers/net/ethernet/intel/ixgb/ixgb_ids.h  |    5 -----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |   10 +++++-----
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
index 99b69ad..bf9a220 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
@@ -32,6 +32,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/pci_ids.h>
 #include "ixgb_hw.h"
 #include "ixgb_ids.h"
 
@@ -96,7 +97,7 @@ static u32 ixgb_mac_reset(struct ixgb_hw *hw)
 	ASSERT(!(ctrl_reg & IXGB_CTRL0_RST));
 #endif
 
-	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID) {
+	if (hw->subsystem_vendor_id == PCI_VENDOR_ID_SUN) {
 		ctrl_reg =  /* Enable interrupt from XFP and SerDes */
 			   IXGB_CTRL1_GPI0_EN |
 			   IXGB_CTRL1_SDP6_DIR |
@@ -271,7 +272,7 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 	}
 
 	/* update phy type for sun specific board */
-	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID)
+	if (hw->subsystem_vendor_id == PCI_VENDOR_ID_SUN)
 		phy_type = ixgb_phy_type_bcm;
 
 	return phy_type;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ids.h b/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
index 2a58847..32c1b30 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
@@ -33,11 +33,6 @@
 ** The Device and Vendor IDs for 10 Gigabit MACs
 **********************************************************************/
 
-#define INTEL_VENDOR_ID             0x8086
-#define INTEL_SUBVENDOR_ID          0x8086
-#define SUN_VENDOR_ID               0x108E
-#define SUN_SUBVENDOR_ID            0x108E
-
 #define IXGB_DEVICE_ID_82597EX      0x1048
 #define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 #define IXGB_DEVICE_ID_82597EX_LR   0x1B48
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5fce363..4e5a060 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -54,13 +54,13 @@ MODULE_PARM_DESC(copybreak,
  *   Class, Class Mask, private data (not used) }
  */
 static DEFINE_PCI_DEVICE_TABLE(ixgb_pci_tbl) = {
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_CX4,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_CX4,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_LR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
@@ -195,7 +195,7 @@ ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
 	u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
 		  IXGB_INT_TXDW | IXGB_INT_LSC;
-	if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
+	if (adapter->hw.subsystem_vendor_id == PCI_VENDOR_ID_SUN)
 		val |= IXGB_INT_GPI0;
 	IXGB_WRITE_REG(&adapter->hw, IMS, val);
 	IXGB_WRITE_FLUSH(&adapter->hw);
-- 
1.7.9.5
