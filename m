From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] i40e: Save off VSI resource count when updating VSI
Date: Tue,  5 Apr 2016 13:17:25 -0700
Message-ID: <1459887455-146634-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43343 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759973AbcDEURk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:40 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

When updating a VSI, save off the number of allocated and unallocated
VSIs as we do when adding a VSI.

Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 4596294..b0fd684 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2157,6 +2157,9 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_get_update_vsi *cmd =
 		(struct i40e_aqc_add_get_update_vsi *)&desc.params.raw;
+	struct i40e_aqc_add_get_update_vsi_completion *resp =
+		(struct i40e_aqc_add_get_update_vsi_completion *)
+		&desc.params.raw;
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
@@ -2168,6 +2171,9 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
 				    sizeof(vsi_ctx->info), cmd_details);
 
+	vsi_ctx->vsis_allocated = le16_to_cpu(resp->vsi_used);
+	vsi_ctx->vsis_unallocated = le16_to_cpu(resp->vsi_free);
+
 	return status;
 }
 
-- 
2.5.5
