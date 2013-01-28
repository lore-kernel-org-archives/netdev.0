From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] e1000e: cleanup: remove e1000_get_cable_length()
Date: Mon, 28 Jan 2013 01:04:20 -0800
Message-ID: <1359363869-32391-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47947 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162Ab3A1JEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:37 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the function e1000_get_cable_length() and replace the two calls
to it with the same function pointer that it would call.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h | 5 -----
 drivers/net/ethernet/intel/e1000e/phy.c   | 4 ++--
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 115656e..896eacc 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -737,11 +737,6 @@ static inline s32 e1e_wphy_locked(struct e1000_hw *hw, u32 offset, u16 data)
 	return hw->phy.ops.write_reg_locked(hw, offset, data);
 }
 
-static inline s32 e1000_get_cable_length(struct e1000_hw *hw)
-{
-	return hw->phy.ops.get_cable_length(hw);
-}
-
 extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
 extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 3cf627b..c4bfbd6 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1960,7 +1960,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 	phy->is_mdix = !!(phy_data & M88E1000_PSSR_MDIX);
 
 	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
-		ret_val = e1000_get_cable_length(hw);
+		ret_val = hw->phy.ops.get_cable_length(hw);
 		if (ret_val)
 			return ret_val;
 
@@ -2024,7 +2024,7 @@ s32 e1000e_get_phy_info_igp(struct e1000_hw *hw)
 
 	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
 	    IGP01E1000_PSSR_SPEED_1000MBPS) {
-		ret_val = e1000_get_cable_length(hw);
+		ret_val = phy->ops.get_cable_length(hw);
 		if (ret_val)
 			return ret_val;
 
-- 
1.7.11.7
