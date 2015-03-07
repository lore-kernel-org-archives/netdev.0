From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: clean up debug_read_register
Date: Sat,  7 Mar 2015 07:03:13 -0800
Message-ID: <1425740603-11280-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38815 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbbCGPD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:28 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There were some additional spaces and strange (double swapping) logic
in this function that I started looking at because sparse was warning.

This fixes the sparse warning and fixes up the other issues.

Change-ID: I72a91a4197cd45921602649040e6bd25e5f17c0a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index fc4817a..fb78bdd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2126,7 +2126,7 @@ i40e_status i40e_aq_send_msg_to_vf(struct i40e_hw *hw, u16 vfid,
  * Read the register using the admin queue commands
  **/
 i40e_status i40e_aq_debug_read_register(struct i40e_hw *hw,
-				u32  reg_addr, u64 *reg_val,
+				u32 reg_addr, u64 *reg_val,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
@@ -2137,17 +2137,15 @@ i40e_status i40e_aq_debug_read_register(struct i40e_hw *hw,
 	if (reg_val == NULL)
 		return I40E_ERR_PARAM;
 
-	i40e_fill_default_direct_cmd_desc(&desc,
-					  i40e_aqc_opc_debug_read_reg);
+	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_debug_read_reg);
 
 	cmd_resp->address = cpu_to_le32(reg_addr);
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
 	if (!status) {
-		*reg_val = ((u64)cmd_resp->value_high << 32) |
-			    (u64)cmd_resp->value_low;
-		*reg_val = le64_to_cpu(*reg_val);
+		*reg_val = ((u64)le32_to_cpu(cmd_resp->value_high) << 32) |
+			   (u64)le32_to_cpu(cmd_resp->value_low);
 	}
 
 	return status;
-- 
1.9.3
