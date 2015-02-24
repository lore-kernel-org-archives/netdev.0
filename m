From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/16] i40e: Fix i40e_ndo_set_vf_spoofchk
Date: Mon, 23 Feb 2015 18:11:18 -0800
Message-ID: <1424743881-30485-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:9068 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbbBXCLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:49 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The netdev op that allows the operator to turn MAC/VLAN spoof checking on
and off did not include the flag for VLAN spoof checking.  This patch
fixes that problem.

Change-ID: Ib4c9e639024a854592d97af22706544881ac3fcb
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 40f042a..5450b9f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2427,7 +2427,8 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable)
 	ctxt.pf_num = pf->hw.pf_id;
 	ctxt.info.valid_sections = cpu_to_le16(I40E_AQ_VSI_PROP_SECURITY_VALID);
 	if (enable)
-		ctxt.info.sec_flags |= I40E_AQ_VSI_SEC_FLAG_ENABLE_MAC_CHK;
+		ctxt.info.sec_flags |= (I40E_AQ_VSI_SEC_FLAG_ENABLE_VLAN_CHK |
+					I40E_AQ_VSI_SEC_FLAG_ENABLE_MAC_CHK);
 	ret = i40e_aq_update_vsi_params(hw, &ctxt, NULL);
 	if (ret) {
 		dev_err(&pf->pdev->dev, "Error %d updating VSI parameters\n",
-- 
1.9.3
