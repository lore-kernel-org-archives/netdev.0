From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: add error checks when initializing the PHY
Date: Mon,  9 Oct 2017 11:39:54 -0700
Message-ID: <20171009184000.80053-5-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50188 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755216AbdJISkX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:23 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Ignoring errors when attempting to identify the PHY can lead to a crash.
Specifically in the case of FW controlled PHYs where the PHY read/write
operations are set to NULL.

Removed redundant comment.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 933c5070f1b6..8cea53b62e1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3192,6 +3192,9 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 
 	/* Identify the PHY or SFP module */
 	ret_val = phy->ops.identify(hw);
+	if (ret_val == IXGBE_ERR_SFP_NOT_SUPPORTED ||
+	    ret_val == IXGBE_ERR_PHY_ADDR_INVALID)
+		return ret_val;
 
 	/* Setup function pointers based on detected hardware */
 	ixgbe_init_mac_link_ops_X550em(hw);
@@ -3394,9 +3397,10 @@ static s32 ixgbe_reset_hw_X550em(struct ixgbe_hw *hw)
 	ixgbe_clear_tx_pending(hw);
 
 	/* PHY ops must be identified and initialized prior to reset */
-
-	/* Identify PHY and related function pointers */
 	status = hw->phy.ops.init(hw);
+	if (status == IXGBE_ERR_SFP_NOT_SUPPORTED ||
+	    status == IXGBE_ERR_PHY_ADDR_INVALID)
+		return status;
 
 	/* start the external PHY */
 	if (hw->phy.type == ixgbe_phy_x550em_ext_t) {
-- 
2.14.2
