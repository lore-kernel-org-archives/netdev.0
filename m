From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] e1000e: use true/false for bool autoneg_false
Date: Fri, 10 Feb 2012 00:08:54 -0800
Message-ID: <1328861337-12810-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3668 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755210Ab2BJIJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:09:02 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

v2 - replaced mac->autoneg_failed == false with !mac->autoneg_failed

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 0d63c3e..a5eb0d4 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -513,8 +513,8 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
 	if ((ctrl & E1000_CTRL_SWDPIN1) && !(status & E1000_STATUS_LU) &&
 	    !(rxcw & E1000_RXCW_C)) {
-		if (mac->autoneg_failed == 0) {
-			mac->autoneg_failed = 1;
+		if (!mac->autoneg_failed) {
+			mac->autoneg_failed = true;
 			return 0;
 		}
 		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link.\n");
@@ -578,8 +578,8 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 	 */
 	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
 	if (!(status & E1000_STATUS_LU) && !(rxcw & E1000_RXCW_C)) {
-		if (mac->autoneg_failed == 0) {
-			mac->autoneg_failed = 1;
+		if (!mac->autoneg_failed) {
+			mac->autoneg_failed = true;
 			return 0;
 		}
 		e_dbg("NOT Rx'ing /C/, disable AutoNeg and force link.\n");
@@ -855,7 +855,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	}
 	if (i == FIBER_LINK_UP_LIMIT) {
 		e_dbg("Never got a valid link from auto-neg!!!\n");
-		mac->autoneg_failed = 1;
+		mac->autoneg_failed = true;
 		/*
 		 * AutoNeg failed to achieve a link, so we'll call
 		 * mac->check_for_link. This routine will force the
@@ -867,9 +867,9 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 			e_dbg("Error while checking for link\n");
 			return ret_val;
 		}
-		mac->autoneg_failed = 0;
+		mac->autoneg_failed = false;
 	} else {
-		mac->autoneg_failed = 0;
+		mac->autoneg_failed = false;
 		e_dbg("Valid Link Found\n");
 	}
 
-- 
1.7.7.6
