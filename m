From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] ixgbe: Add reset for X550 device
Date: Tue,  9 Jun 2015 18:10:18 -0700
Message-ID: <1433898629-76729-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10750 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933118AbbFJBKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:43 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds a PHY reset function ixgbe_reset_phy_t_X550em. Which
allows devices that have LASI support in enable their interrupt.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 3ca0777..a48134e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1385,6 +1385,22 @@ static s32 ixgbe_setup_internal_phy_t_x550em(struct ixgbe_hw *hw)
 	return ixgbe_setup_ixfi_x550em(hw, &force_speed);
 }
 
+/** ixgbe_reset_phy_t_X550em - Performs X557 PHY reset and enables LASI
+ *  @hw: pointer to hardware structure
+ **/
+static s32 ixgbe_reset_phy_t_X550em(struct ixgbe_hw *hw)
+{
+	s32 status;
+
+	status = ixgbe_reset_phy_generic(hw);
+
+	if (status)
+		return status;
+
+	/* Configure Link Status Alarm and Temperature Threshold interrupts */
+	return ixgbe_enable_lasi_ext_t_x550em(hw);
+}
+
 /** ixgbe_init_phy_ops_X550em - PHY/SFP specific init
  *  @hw: pointer to hardware structure
  *
@@ -1454,6 +1470,7 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		}
 
 		phy->ops.handle_lasi = ixgbe_handle_lasi_ext_t_x550em;
+		phy->ops.reset = ixgbe_reset_phy_t_X550em;
 		break;
 	default:
 		break;
-- 
2.4.2
