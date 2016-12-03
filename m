From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/18] i40e: remove error_param_int label from i40e_vc_config_promiscuous_mode_msg
Date: Sat,  3 Dec 2016 01:19:15 -0800
Message-ID: <20161203091930.14268-4-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6457 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbcLCJUa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:30 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This label is unnecessary, as are jumping to a block that checks aq_ret
and then immediately skipping it and returning. So just jump straight to
the error_param and remove this unnecessary label.

Also use goto error_param even in the last check for style consistency.

Change-ID: If487c7d10c4048e37c594e5eca167693aaed45f6
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 53b46553..46908c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1536,7 +1536,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 				vf->vf_id,
 				i40e_stat_str(&pf->hw, aq_ret),
 				i40e_aq_str(&pf->hw, aq_err));
-			goto error_param_int;
+			goto error_param;
 		}
 	}
 
@@ -1581,15 +1581,16 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 							     allmulti, NULL,
 							     true);
 		aq_err = pf->hw.aq.asq_last_status;
-		if (aq_ret)
+		if (aq_ret) {
 			dev_err(&pf->pdev->dev,
 				"VF %d failed to set unicast promiscuous mode %8.8x err %s aq_err %s\n",
 				vf->vf_id, info->flags,
 				i40e_stat_str(&pf->hw, aq_ret),
 				i40e_aq_str(&pf->hw, aq_err));
+			goto error_param;
+		}
 	}
 
-error_param_int:
 	if (!aq_ret) {
 		dev_info(&pf->pdev->dev,
 			 "VF %d successfully set unicast promiscuous mode\n",
-- 
2.9.3
