From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: use correct struct for get and update vsi params
Date: Mon,  6 Jan 2014 04:30:32 -0800
Message-ID: <1389011436-18424-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24692 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbaAFMao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:44 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The get_vsi_params and update_vsi_params functions were using a
different command struct that just happened to have an seid element in
the right place and so worked correctly anyway.  This patch fixes the
functions to use the right data struct.

There is no actual logic change.

Change-Id: I513b5e1dc293dfd5b2ba4fa443cbdbfa608d9d19
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index e5694b9..161d6ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -748,8 +748,8 @@ i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
-	struct i40e_aqc_switch_seid *cmd =
-		(struct i40e_aqc_switch_seid *)&desc.params.raw;
+	struct i40e_aqc_add_get_update_vsi *cmd =
+		(struct i40e_aqc_add_get_update_vsi *)&desc.params.raw;
 	struct i40e_aqc_add_get_update_vsi_completion *resp =
 		(struct i40e_aqc_add_get_update_vsi_completion *)
 		&desc.params.raw;
@@ -758,7 +758,7 @@ i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 	i40e_fill_default_direct_cmd_desc(&desc,
 					  i40e_aqc_opc_get_vsi_parameters);
 
-	cmd->seid = cpu_to_le16(vsi_ctx->seid);
+	cmd->uplink_seid = cpu_to_le16(vsi_ctx->seid);
 
 	desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_BUF);
 	if (sizeof(vsi_ctx->info) > I40E_AQ_LARGE_BUF)
@@ -792,13 +792,13 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
-	struct i40e_aqc_switch_seid *cmd =
-		(struct i40e_aqc_switch_seid *)&desc.params.raw;
+	struct i40e_aqc_add_get_update_vsi *cmd =
+		(struct i40e_aqc_add_get_update_vsi *)&desc.params.raw;
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
 					  i40e_aqc_opc_update_vsi_parameters);
-	cmd->seid = cpu_to_le16(vsi_ctx->seid);
+	cmd->uplink_seid = cpu_to_le16(vsi_ctx->seid);
 
 	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
 	if (sizeof(vsi_ctx->info) > I40E_AQ_LARGE_BUF)
-- 
1.8.3.1
