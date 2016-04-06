From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: Lower some message levels
Date: Tue,  5 Apr 2016 20:36:06 -0700
Message-ID: <1459913769-56510-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61852 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760048AbcDFDg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:29 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

These conditions can happen any time VFs are enabled or disabled and are
not really indicative of fatal problems unless they happen continuously.

Lower the log level so that people don't get scared.

Change-ID: I1ceb4adbd10d03cbeed54d1f5b7f20d60328351d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 169c256..9924503 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1232,8 +1232,8 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 	/* single place to detect unsuccessful return values */
 	if (v_retval) {
 		vf->num_invalid_msgs++;
-		dev_err(&pf->pdev->dev, "VF %d failed opcode %d, error: %d\n",
-			vf->vf_id, v_opcode, v_retval);
+		dev_info(&pf->pdev->dev, "VF %d failed opcode %d, retval: %d\n",
+			 vf->vf_id, v_opcode, v_retval);
 		if (vf->num_invalid_msgs >
 		    I40E_DEFAULT_NUM_INVALID_MSGS_ALLOWED) {
 			dev_err(&pf->pdev->dev,
@@ -1251,9 +1251,9 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 	aq_ret = i40e_aq_send_msg_to_vf(hw, abs_vf_id,	v_opcode, v_retval,
 					msg, msglen, NULL);
 	if (aq_ret) {
-		dev_err(&pf->pdev->dev,
-			"Unable to send the message to VF %d aq_err %d\n",
-			vf->vf_id, pf->hw.aq.asq_last_status);
+		dev_info(&pf->pdev->dev,
+			 "Unable to send the message to VF %d aq_err %d\n",
+			 vf->vf_id, pf->hw.aq.asq_last_status);
 		return -EIO;
 	}
 
-- 
2.5.5
