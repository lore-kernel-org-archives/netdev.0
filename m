From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: rename wol_supported to more fitting wol_enabled
Date: Sat, 20 Apr 2013 02:49:02 -0700
Message-ID: <1366451353-24714-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14906 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127Ab3DTJtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:18 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The variable wol_supported really is just checking whether it is enabled, rather
than whether it is supported. If it is enabled it will be supported, but this
does not necessarily hold true the other way around. This patch renames the
variable to avoid confusion.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 7946da9..6dbdd4f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1055,7 +1055,7 @@ mac_reset_top:
 		 * LMS state either.
 		 */
 		if ((hw->phy.multispeed_fiber && hw->mng_fw_enabled) ||
-		    hw->wol_supported)
+		    hw->wol_enabled)
 			hw->mac.orig_autoc =
 				(hw->mac.orig_autoc & ~IXGBE_AUTOC_LMS_MASK) |
 				curr_lms;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 783efbb..891724a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7540,9 +7540,9 @@ skip_sriov:
 	/* WOL not supported for all devices */
 	adapter->wol = 0;
 	hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
-	hw->wol_supported = ixgbe_wol_supported(adapter, pdev->device,
+	hw->wol_enabled = ixgbe_wol_supported(adapter, pdev->device,
 						pdev->subsystem_device);
-	if (hw->wol_supported)
+	if (hw->wol_enabled)
 		adapter->wol = IXGBE_WUFC_MAG;
 
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 2661dcf..100dd92 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3000,7 +3000,7 @@ struct ixgbe_hw {
 	bool				force_full_reset;
 	bool				allow_unsupported_sfp;
 	bool				mng_fw_enabled;
-	bool				wol_supported;
+	bool				wol_enabled;
 };
 
 struct ixgbe_info {
-- 
1.7.11.7
