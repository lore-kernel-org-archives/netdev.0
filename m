From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  05/11] ixgbe: remove unnecessary duplication of PCIe bandwidth display
Date: Tue, 29 Oct 2013 05:02:25 -0700
Message-ID: <1383048151-15002-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25560 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754813Ab3J2MCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:39 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch removes the unnecessary display of PCIe bandwidth twice. Since the
ixgbe_check_minimum_link does a better job, and ensures accurate detection on
even complex chains, this older check is no longer necessary.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 36 ++++++++++-----------------
 1 file changed, 13 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9753c8a..a7d1a1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7752,29 +7752,6 @@ skip_sriov:
 	if (ixgbe_pcie_from_parent(hw))
 		ixgbe_get_parent_bus_info(adapter);
 
-	/* print bus type/speed/width info */
-	e_dev_info("(PCI Express:%s:%s) %pM\n",
-		   (hw->bus.speed == ixgbe_bus_speed_8000 ? "8.0GT/s" :
-		    hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0GT/s" :
-		    hw->bus.speed == ixgbe_bus_speed_2500 ? "2.5GT/s" :
-		    "Unknown"),
-		   (hw->bus.width == ixgbe_bus_width_pcie_x8 ? "Width x8" :
-		    hw->bus.width == ixgbe_bus_width_pcie_x4 ? "Width x4" :
-		    hw->bus.width == ixgbe_bus_width_pcie_x1 ? "Width x1" :
-		    "Unknown"),
-		   netdev->dev_addr);
-
-	err = ixgbe_read_pba_string_generic(hw, part_str, IXGBE_PBANUM_LENGTH);
-	if (err)
-		strncpy(part_str, "Unknown", IXGBE_PBANUM_LENGTH);
-	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
-		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, PBA No: %s\n",
-			   hw->mac.type, hw->phy.type, hw->phy.sfp_type,
-		           part_str);
-	else
-		e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
-			   hw->mac.type, hw->phy.type, part_str);
-
 	/* calculate the expected PCIe bandwidth required for optimal
 	 * performance. Note that some older parts will never have enough
 	 * bandwidth due to being older generation PCIe parts. We clamp these
@@ -7790,6 +7767,19 @@ skip_sriov:
 	}
 	ixgbe_check_minimum_link(adapter, expected_gts);
 
+	err = ixgbe_read_pba_string_generic(hw, part_str, IXGBE_PBANUM_LENGTH);
+	if (err)
+		strncpy(part_str, "Unknown", IXGBE_PBANUM_LENGTH);
+	if (ixgbe_is_sfp(hw) && hw->phy.sfp_type != ixgbe_sfp_type_not_present)
+		e_dev_info("MAC: %d, PHY: %d, SFP+: %d, PBA No: %s\n",
+			   hw->mac.type, hw->phy.type, hw->phy.sfp_type,
+		           part_str);
+	else
+		e_dev_info("MAC: %d, PHY: %d, PBA No: %s\n",
+			   hw->mac.type, hw->phy.type, part_str);
+
+	e_dev_info("%pM\n", netdev->dev_addr);
+
 	/* reset the hardware with the new settings */
 	err = hw->mac.ops.start_hw(hw);
 	if (err == IXGBE_ERR_EEPROM_VERSION) {
-- 
1.8.3.1
