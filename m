From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: remove obsolete version check
Date: Thu, 15 Oct 2015 02:39:55 -0700
Message-ID: <1444902004-14433-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31273 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412AbbJOJma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:30 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This version check only applies to very, very old firmware,
that only ran on A0 hardware, which we never shipped and don't
support in this driver anyway. Remove it, before somebody
gets hurt.

Change-ID: I3752d090ff488acf98ee76b075af961e9c968ee4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7c4add8..c4f26eb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6353,12 +6353,6 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 		}
 	} while (err);
 
-	if (((pf->hw.aq.fw_maj_ver == 2) && (pf->hw.aq.fw_min_ver < 22)) ||
-	    (pf->hw.aq.fw_maj_ver < 2)) {
-		pf->hw.func_caps.num_msix_vectors++;
-		pf->hw.func_caps.num_msix_vectors_vf++;
-	}
-
 	if (pf->hw.debug_mask & I40E_DEBUG_USER)
 		dev_info(&pf->pdev->dev,
 			 "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
-- 
2.4.3
