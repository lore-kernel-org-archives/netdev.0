From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] e1000: limit udelay for phy changes to 10000us
Date: Sat, 20 Apr 2013 20:31:35 -0700
Message-ID: <1366515095-17734-1-git-send-email-andi@firstfloor.org>
Cc: netdev@vger.kernel.org, Andi Kleen <ak@linux.intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64412 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557Ab3DUDby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 23:31:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

If you really want 100000us you should really use mdelay or so.

Found by the LTO kernel build

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 2918c97..a12a1c7 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1169,7 +1169,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
-						     100000,
+						     10000,
 						     &link);
 		if (ret_val)
 			goto out;
@@ -1180,7 +1180,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
-						     100000,
+						     10000,
 						     &link);
 		if (ret_val)
 			goto out;
@@ -1642,7 +1642,7 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 		 * it across the board.
 		 */
 		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
-		if (ret_val) {
+		if (ret_val && usec_interval > 0) {
 			/*
 			 * If the first read fails, another entity may have
 			 * ownership of the resources, wait and try again to
-- 
1.7.7.6
