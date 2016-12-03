From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] i40e: Remove unreachable code
Date: Sat,  3 Dec 2016 01:19:24 -0800
Message-ID: <20161203091930.14268-13-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Henry Tieman <henry.w.tieman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28618 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751708AbcLCJUn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:43 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Tieman <henry.w.tieman@intel.com>

The code at the end of i40e_read_phy_register_clause22() contained
unreachable code and redundant control statements.

This change removes the unreachable code. And deletes the redundant
goto statement and if statement.

Change-ID: I713032b1585396f40f903cbcfdea987abd874400
Signed-off-by: Henry Tieman <henry.w.tieman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index e83e8e3..fc7ce02 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -4439,19 +4439,12 @@ i40e_status i40e_read_phy_register_clause22(struct i40e_hw *hw,
 	if (status) {
 		i40e_debug(hw, I40E_DEBUG_PHY,
 			   "PHY: Can't write command to external PHY.\n");
-		goto phy_read_end;
-	}
-
-	if (!status) {
+	} else {
 		command = rd32(hw, I40E_GLGEN_MSRWD(port_num));
 		*value = (command & I40E_GLGEN_MSRWD_MDIRDDATA_MASK) >>
 			 I40E_GLGEN_MSRWD_MDIRDDATA_SHIFT;
-	} else {
-		i40e_debug(hw, I40E_DEBUG_PHY,
-			   "PHY: Can't read register value from external PHY.\n");
 	}
 
-phy_read_end:
 	return status;
 }
 
-- 
2.9.3
