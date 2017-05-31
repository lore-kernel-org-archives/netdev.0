From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: fix incorrect status check
Date: Wed, 31 May 2017 14:19:36 -0700
Message-ID: <20170531211936.63417-16-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17444 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751220AbdEaVT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:56 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Check for ret_val instead of !ret_val to allow the rest of
the code to execute and configure the speed properly.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 80824fec15d2..72d84a065e34 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1750,14 +1750,14 @@ ixgbe_setup_mac_link_sfp_n(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 	if (ret_val == IXGBE_ERR_SFP_NOT_PRESENT)
 		return 0;
 
-	if (!ret_val)
+	if (ret_val)
 		return ret_val;
 
 	/* Configure internal PHY for native SFI based on module type */
 	ret_val = hw->mac.ops.read_iosf_sb_reg(hw,
 				IXGBE_KRM_PMD_FLX_MASK_ST20(hw->bus.lan_id),
 				IXGBE_SB_IOSF_TARGET_KR_PHY, &reg_phy_int);
-	if (!ret_val)
+	if (ret_val)
 		return ret_val;
 
 	reg_phy_int &= IXGBE_KRM_PMD_FLX_MASK_ST20_SFI_10G_DA;
@@ -1767,7 +1767,7 @@ ixgbe_setup_mac_link_sfp_n(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 	ret_val = hw->mac.ops.write_iosf_sb_reg(hw,
 				IXGBE_KRM_PMD_FLX_MASK_ST20(hw->bus.lan_id),
 				IXGBE_SB_IOSF_TARGET_KR_PHY, reg_phy_int);
-	if (!ret_val)
+	if (ret_val)
 		return ret_val;
 
 	/* Setup SFI internal link. */
@@ -1798,7 +1798,7 @@ ixgbe_setup_mac_link_sfp_x550a(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 	if (ret_val == IXGBE_ERR_SFP_NOT_PRESENT)
 		return 0;
 
-	if (!ret_val)
+	if (ret_val)
 		return ret_val;
 
 	/* Configure internal PHY for KR/KX. */
-- 
2.12.2
