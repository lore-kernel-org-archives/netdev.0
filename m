From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Fix uninitialized variable
Date: Sun,  1 May 2016 17:06:12 -0700
Message-ID: <1462147581-135254-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbcEBAG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:27 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We have an uninitialized variable warning for valid_len for one case in
validate_vf_mesg. To fix this, just initialize it to 0 at the top of the
function and remove all of the now redundant assignments to 0 in the
individual cases.

Change-Id: Iacbd97f4c521ed8d662eef803a598d8707708cfd
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a8a65e0..a534fe6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2356,7 +2356,7 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 				   u32 v_retval, u8 *msg, u16 msglen)
 {
 	bool err_msg_format = false;
-	int valid_len;
+	int valid_len = 0;
 
 	/* Check if VF is disabled. */
 	if (test_bit(I40E_VF_STAT_DISABLED, &vf->vf_states))
@@ -2368,13 +2368,10 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 		valid_len = sizeof(struct i40e_virtchnl_version_info);
 		break;
 	case I40E_VIRTCHNL_OP_RESET_VF:
-		valid_len = 0;
 		break;
 	case I40E_VIRTCHNL_OP_GET_VF_RESOURCES:
 		if (VF_IS_V11(vf))
 			valid_len = sizeof(u32);
-		else
-			valid_len = 0;
 		break;
 	case I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE:
 		valid_len = sizeof(struct i40e_virtchnl_txq_info);
@@ -2489,7 +2486,6 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 		}
 		break;
 	case I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS:
-		valid_len = 0;
 		break;
 	case I40E_VIRTCHNL_OP_SET_RSS_HENA:
 		valid_len = sizeof(struct i40e_virtchnl_rss_hena);
-- 
2.5.5
