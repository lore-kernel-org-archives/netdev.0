From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked() declaration
Date: Sun,  9 Mar 2014 19:19:02 -0600
Message-ID: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
Cc: netdev@vger.kernel.org, Don Skidmore <donald.c.skidmore@intel.com>
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40781 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaCJBWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 21:22:30 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so6566045pad.30
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 18:22:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit c97506ab0e22 ("ixgbe: Add check for FW veto bit")
introduced the new function ixgbe_check_reset_blocked() with a minor
issue in declaration. Fix the declaration by changing the type
specifier to bool as the definition returns a boolean value.
Additionally all ixgbe_check_reset_blocked() callers are expected to
return a boolean value.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index d2caae4750e0..05e083c99000 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -106,7 +106,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
  * have this bit just return false since the link can not be blocked
  * via this method.
  **/
-s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
+bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw)
 {
 	u32 mmngc;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index b4d4323666b8..52a9254c34bc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -131,7 +131,7 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
                                                ixgbe_link_speed *speed,
                                                bool *autoneg);
-s32 ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
+bool ixgbe_check_reset_blocked(struct ixgbe_hw *hw);
 
 /* PHY specific */
 s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
