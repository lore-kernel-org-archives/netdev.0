From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e: make error message more useful
Date: Wed,  2 Dec 2015 00:25:29 -0800
Message-ID: <1449044735-68599-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:12553 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570AbbLBIZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:42 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If we get an invalid message from a VF, we should tell the user which VF
is being naughty, rather than making them guess.

Change-ID: I9252cef7baea3d8584043ed6ff12619a94e2f99c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9c54ca2..26f247d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1094,8 +1094,8 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 	/* single place to detect unsuccessful return values */
 	if (v_retval) {
 		vf->num_invalid_msgs++;
-		dev_err(&pf->pdev->dev, "Failed opcode %d Error: %d\n",
-			v_opcode, v_retval);
+		dev_err(&pf->pdev->dev, "VF %d failed opcode %d, error: %d\n",
+			vf->vf_id, v_opcode, v_retval);
 		if (vf->num_invalid_msgs >
 		    I40E_DEFAULT_NUM_INVALID_MSGS_ALLOWED) {
 			dev_err(&pf->pdev->dev,
-- 
2.5.0
