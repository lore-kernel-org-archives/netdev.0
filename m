From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: be more informative
Date: Wed, 18 Dec 2013 22:34:48 -0800
Message-ID: <1387434891-19719-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab3LSGfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:35:02 -0500
In-Reply-To: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the VF sends a bad message, be more informative about what it
actually is.

Change-Id: I89e06d2db416a1d05aeea016dd6e8b7870cae99a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4cd6c8c..cc8fa2a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1667,7 +1667,8 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 	ret = i40e_vc_validate_vf_msg(vf, v_opcode, v_retval, msg, msglen);
 
 	if (ret) {
-		dev_err(&pf->pdev->dev, "invalid message from vf %d\n", vf_id);
+		dev_err(&pf->pdev->dev, "Invalid message from vf %d, opcode %d, len %d\n",
+			vf_id, v_opcode, msglen);
 		return ret;
 	}
 	wr32(hw, I40E_VFGEN_RSTAT1(vf_id), I40E_VFR_VFACTIVE);
-- 
1.8.3.1
