From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] i40e: Fix up return code
Date: Tue,  5 Apr 2016 13:17:26 -0700
Message-ID: <1459887455-146634-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759953AbcDEURk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:40 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The i40e_common.c typically uses i40e_status as a return code,
but got missed this one case.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index b0fd684..8276a13 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1901,13 +1901,13 @@ i40e_status i40e_aq_set_phy_int_mask(struct i40e_hw *hw,
  *
  * Reset the external PHY.
  **/
-enum i40e_status_code i40e_aq_set_phy_debug(struct i40e_hw *hw, u8 cmd_flags,
-					struct i40e_asq_cmd_details *cmd_details)
+i40e_status i40e_aq_set_phy_debug(struct i40e_hw *hw, u8 cmd_flags,
+				  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_phy_debug *cmd =
 		(struct i40e_aqc_set_phy_debug *)&desc.params.raw;
-	enum i40e_status_code status;
+	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
 					  i40e_aqc_opc_set_phy_debug);
-- 
2.5.5
