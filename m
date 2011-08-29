From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: fix ixgbe_fc_autoneg_fiber bug
Date: Mon, 29 Aug 2011 01:41:06 -0700
Message-ID: <1314607268-26958-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35897 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab1H2IlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:18 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

A logic error in ixgbe_fc_autoneg_fiber() that treated a masked u32 as a
boolean would make it so we would never fall hit a error check case.  So
now I force the u32 to a boolean value with '!!'.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index fc1375f..90a04e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2121,8 +2121,8 @@ static s32 ixgbe_fc_autoneg_fiber(struct ixgbe_hw *hw)
 	 */
 
 	linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
-	if (((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
-	    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
+	if ((!!(linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
+	    (!!(linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
 		ret_val = IXGBE_ERR_FC_NOT_NEGOTIATED;
 		goto out;
 	}
-- 
1.7.6
