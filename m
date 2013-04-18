From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: Enable support for recognizing PCI-e Gen3 link speed
Date: Wed, 17 Apr 2013 23:33:56 -0700
Message-ID: <1366266841-12466-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7701 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965309Ab3DRGeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 02:34:07 -0400
In-Reply-To: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for displaying PCIe Gen3 link speed, which was
previously missing from the driver.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 2 ++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index f8d3dec..3f66abc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -635,6 +635,9 @@ s32 ixgbe_get_bus_info_generic(struct ixgbe_hw *hw)
 	case IXGBE_PCI_LINK_SPEED_5000:
 		hw->bus.speed = ixgbe_bus_speed_5000;
 		break;
+	case IXGBE_PCI_LINK_SPEED_8000:
+		hw->bus.speed = ixgbe_bus_speed_8000;
+		break;
 	default:
 		hw->bus.speed = ixgbe_bus_speed_unknown;
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0e7f0dd..54e7d09 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7490,7 +7490,8 @@ skip_sriov:
 
 	/* print bus type/speed/width info */
 	e_dev_info("(PCI Express:%s:%s) %pM\n",
-		   (hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0GT/s" :
+		   (hw->bus.speed == ixgbe_bus_speed_8000 ? "8.0GT/s" :
+		    hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0GT/s" :
 		    hw->bus.speed == ixgbe_bus_speed_2500 ? "2.5GT/s" :
 		    "Unknown"),
 		   (hw->bus.width == ixgbe_bus_width_pcie_x8 ? "Width x8" :
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6652e96..05df36e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1827,6 +1827,7 @@ enum {
 #define IXGBE_PCI_LINK_SPEED      0xF
 #define IXGBE_PCI_LINK_SPEED_2500 0x1
 #define IXGBE_PCI_LINK_SPEED_5000 0x2
+#define IXGBE_PCI_LINK_SPEED_8000 0x3
 #define IXGBE_PCI_HEADER_TYPE_REGISTER  0x0E
 #define IXGBE_PCI_HEADER_TYPE_MULTIFUNC 0x80
 #define IXGBE_PCI_DEVICE_CONTROL2_16ms  0x0005
@@ -2650,6 +2651,7 @@ enum ixgbe_bus_speed {
 	ixgbe_bus_speed_133     = 133,
 	ixgbe_bus_speed_2500    = 2500,
 	ixgbe_bus_speed_5000    = 5000,
+	ixgbe_bus_speed_8000    = 8000,
 	ixgbe_bus_speed_reserved
 };
 
-- 
1.7.11.7
