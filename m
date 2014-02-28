From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/6] ixgbe: fix bit toggled for 82599 reset fix.
Date: Thu, 27 Feb 2014 20:32:42 -0800
Message-ID: <1393561965-3688-4-git-send-email-aaron.f.brown@intel.com>
References: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53821 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbaB1EgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 23:36:10 -0500
In-Reply-To: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The current code doesn't toggle the correct bit to reset the data pipeline
on Restart_AN assertion.  This patch corrects that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 1c31d2d..e919c28 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2395,7 +2395,8 @@ static s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw)
 	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 
 	/* Write AUTOC register with toggled LMS[2] bit and Restart_AN */
-	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg ^ IXGBE_AUTOC_LMS_1G_AN);
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC,
+			autoc_reg ^ (0x4 << IXGBE_AUTOC_LMS_SHIFT));
 
 	/* Wait for AN to leave state 0 */
 	for (i = 0; i < 10; i++) {
-- 
1.8.5.GIT
