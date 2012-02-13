From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] e1000e: cleanup: always return 0
Date: Mon, 13 Feb 2012 13:47:41 -0800
Message-ID: <1329169670-5403-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40106 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755595Ab2BMVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:56 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

These are a few instances of returning a value that can only be 0 so just
use a 'return 0' to make it more obvious.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c   |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    2 +-
 drivers/net/ethernet/intel/e1000e/mac.c     |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 024ac24..05e9a29 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -796,7 +796,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	 * otherwise, commit the checksum to the flash NVM.
 	 */
 	if (hw->nvm.type != e1000_nvm_flash_hw)
-		return ret_val;
+		return 0;
 
 	/* Check for pending operations. */
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 6ab7254..ce348cd 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1948,7 +1948,7 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	u16 data;
 
 	if (phy->type == e1000_phy_ife)
-		return ret_val;
+		return 0;
 
 	phy_ctrl = er32(PHY_CTRL);
 
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index ce8a55a..b3b2f9e 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -444,7 +444,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!link)
-		return ret_val;	/* No link detected */
+		return 0;	/* No link detected */
 
 	mac->get_link_status = false;
 
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 323cb14..a8b99ba 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1916,7 +1916,7 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 
 	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
 
-	return ret_val;
+	return 0;
 }
 
 /**
-- 
1.7.7.6
