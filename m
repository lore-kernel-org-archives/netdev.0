From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: Remove FCoE in i40e_virtchnl_pf.c code
Date: Thu, 12 Dec 2013 04:40:51 -0800
Message-ID: <1386852051-27907-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26106 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790Ab3LLMlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 07:41:07 -0500
In-Reply-To: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

Remove FCoE code from the VF interface, as the feature will
not be supported on VF interfaces.

Change-Id: Ie9db04fa2e37fa14ac3e73a9c20980348d931357
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 29 ++--------------------
 1 file changed, 2 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index e7bdd47..68e1f8e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -521,6 +521,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
 				    0, true, false);
 	}
+
 	if (!f) {
 		dev_err(&pf->pdev->dev, "Unable to add ucast filter\n");
 		ret = -ENOMEM;
@@ -763,6 +764,7 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 		vf->lan_vsi_index = 0;
 		vf->lan_vsi_id = 0;
 	}
+
 	/* reset some of the state varibles keeping
 	 * track of the resources
 	 */
@@ -1777,30 +1779,6 @@ error_param:
 }
 
 /**
- * i40e_vc_fcoe_msg
- * @vf: pointer to the vf info
- * @msg: pointer to the msg buffer
- * @msglen: msg length
- *
- * called from the vf for the fcoe msgs
- **/
-static int i40e_vc_fcoe_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
-{
-	i40e_status aq_ret = 0;
-
-	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VF_STAT_FCOEENA, &vf->vf_states)) {
-		aq_ret = I40E_ERR_PARAM;
-		goto error_param;
-	}
-	aq_ret = I40E_ERR_NOT_IMPLEMENTED;
-
-error_param:
-	/* send the response to the vf */
-	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_FCOE, aq_ret);
-}
-
-/**
  * i40e_vc_validate_vf_msg
  * @vf: pointer to the vf info
  * @msg: pointer to the msg buffer
@@ -1973,9 +1951,6 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 	case I40E_VIRTCHNL_OP_GET_STATS:
 		ret = i40e_vc_get_stats_msg(vf, msg, msglen);
 		break;
-	case I40E_VIRTCHNL_OP_FCOE:
-		ret = i40e_vc_fcoe_msg(vf, msg, msglen);
-		break;
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
 		dev_err(&pf->pdev->dev,
-- 
1.8.3.1
