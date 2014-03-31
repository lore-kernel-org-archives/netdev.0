From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] ixgbe: fix ixgbe_check_reset_blocked() declaration
Date: Mon, 31 Mar 2014 16:34:51 -0700
Message-ID: <1396308899-20926-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34702 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbaCaXg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:29 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit c97506ab0e22 ("ixgbe: Add check for FW veto bit")
introduced the new function ixgbe_check_reset_blocked() with a minor
issue in declaration. Fix the declaration by changing the type
specifier to bool as the definition returns a boolean value.
Additionally all ixgbe_check_reset_blocked() callers are expected to
return a boolean value.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index ad51c12..23f7652 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -107,7 +107,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
  * have this bit just return false since the link can not be blocked
  * via this method.
  **/
-s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
+bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
 {
 	u32 mmngc;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index 4a456c9..0bb047f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -128,7 +128,7 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
                                                ixgbe_link_speed *speed,
                                                bool *autoneg);
-s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
+bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
 
 /* PHY specific */
 s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
-- 
1.9.0
