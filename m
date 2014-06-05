From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/13] i40e: remove check for large buffer
Date: Thu,  5 Jun 2014 03:12:51 -0700
Message-ID: <1401963181-11110-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19645 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814AbaFEKNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:13:05 -0400
In-Reply-To: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

We introduced this check in case this structure changed in the future,
the AQ definition is now mature enough that this check is no longer necessary.

Change-ID: Ic66321d0a08557dc9d8cb84029185352cb534330
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2329e2f..a31e3d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1062,8 +1062,6 @@ i40e_status i40e_aq_add_vsi(struct i40e_hw *hw,
 	cmd->vsi_flags = cpu_to_le16(vsi_ctx->flags);
 
 	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
-	if (sizeof(vsi_ctx->info) > I40E_AQ_LARGE_BUF)
-		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
 				    sizeof(vsi_ctx->info), cmd_details);
@@ -1204,8 +1202,6 @@ i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 	cmd->uplink_seid = cpu_to_le16(vsi_ctx->seid);
 
 	desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_BUF);
-	if (sizeof(vsi_ctx->info) > I40E_AQ_LARGE_BUF)
-		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
 				    sizeof(vsi_ctx->info), NULL);
@@ -1244,8 +1240,6 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 	cmd->uplink_seid = cpu_to_le16(vsi_ctx->seid);
 
 	desc.flags |= cpu_to_le16((u16)(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_RD));
-	if (sizeof(vsi_ctx->info) > I40E_AQ_LARGE_BUF)
-		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
 				    sizeof(vsi_ctx->info), cmd_details);
-- 
1.9.3
