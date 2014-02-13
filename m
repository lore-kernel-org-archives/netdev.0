From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 06/15] i40e: remove dead code
Date: Thu, 13 Feb 2014 03:48:44 -0800
Message-ID: <1392292133-32120-7-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754308AbaBMLvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:12 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This looks like a cut and paste error. The code makes no sense where
it is, and accomplishes nothing. Since we've removed the goto, we can
also get rid of the extraneous brackets.

Change-ID: I9315e3eafeee0a5713c94b0dc57b58b60a849124
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b9d1c1c..299372b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -408,18 +408,10 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 				 "Could not allocate VF broadcast filter\n");
 	}
 
-	if (!f) {
-		dev_err(&pf->pdev->dev, "Unable to add ucast filter\n");
-		ret = -ENOMEM;
-		goto error_alloc_vsi_res;
-	}
-
 	/* program mac filter */
 	ret = i40e_sync_vsi_filters(vsi);
-	if (ret) {
+	if (ret)
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
-		goto error_alloc_vsi_res;
-	}
 
 error_alloc_vsi_res:
 	return ret;
-- 
1.8.5.GIT
