From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] igb: limit udelay for phy changes to 10000us
Date: Thu, 25 Apr 2013 21:57:06 -0700
Message-ID: <1366952231-16727-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53194 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab3DZE5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:17 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

If you really want 100000us you should really use mdelay or so.

Found by the LTO kernel build

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index fd46add..115b0da 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1130,7 +1130,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		hw_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
 
-		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 100000, &link);
+		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 10000, &link);
 		if (ret_val)
 			goto out;
 
@@ -1138,7 +1138,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			hw_dbg("Link taking longer than expected.\n");
 
 		/* Try once more */
-		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 100000, &link);
+		ret_val = igb_phy_has_link(hw, PHY_FORCE_LIMIT, 10000, &link);
 		if (ret_val)
 			goto out;
 	}
@@ -1590,7 +1590,7 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 		 * it across the board.
 		 */
 		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
-		if (ret_val) {
+		if (ret_val && usec_interval > 0) {
 			/* If the first read fails, another entity may have
 			 * ownership of the resources, wait and try again to
 			 * see if they have relinquished the resources yet.
-- 
1.7.11.7
