From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: fix incorrect variable assignment
Date: Wed, 26 Jul 2017 03:31:10 -0700
Message-ID: <20170726103123.76743-2-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Gustavo A R Silva <garsilva@embeddedor.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26362 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751695AbdGZKcG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:32:06 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo A R Silva <garsilva@embeddedor.com>

Fix incorrect variable assignment.
Based on line 1511: aq_ret = I40_ERR_PARAM; the correct variable to be
used in this instance is aq_ret instead of ret. Also, variable ret is
updated at line 1602 just before return, so assigning a value to this
variable in this code block is useless.

Addresses-Coverity-ID: 1397693
Signed-off-by: Gustavo A R Silva <garsilva@embeddedor.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ecbe40ea8ffe..ba327e90f32a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1567,7 +1567,7 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 			dev_err(&pf->pdev->dev,
 				"VF %d requested polling mode: this feature is supported only when the device is running in single function per port (SFP) mode\n",
 				 vf->vf_id);
-			ret = I40E_ERR_PARAM;
+			aq_ret = I40E_ERR_PARAM;
 			goto err;
 		}
 		vfres->vf_offload_flags |= VIRTCHNL_VF_OFFLOAD_RX_POLLING;
-- 
2.13.3
