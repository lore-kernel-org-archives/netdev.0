From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: Remove a FW workaround for Number of MSIX vectors
Date: Wed,  5 Mar 2014 20:21:38 -0800
Message-ID: <1394079704-1108-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24583 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174AbaCFEVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:53 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The Number of MSIX vectors being reported is correct and hence
we need a check to do the right thing for FWs before and after.

Change-ID: I50902d1c848adcb960ea49ac73f7865ca871a1c3
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 942d20f..724764f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5097,6 +5097,12 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 	/* increment MSI-X count because current FW skips one */
 	pf->hw.func_caps.num_msix_vectors++;
 
+	if (((pf->hw.aq.fw_maj_ver == 2) && (pf->hw.aq.fw_min_ver < 22)) ||
+	    (pf->hw.aq.fw_maj_ver < 2)) {
+		pf->hw.func_caps.num_msix_vectors++;
+		pf->hw.func_caps.num_msix_vectors_vf++;
+	}
+
 	if (pf->hw.debug_mask & I40E_DEBUG_USER)
 		dev_info(&pf->pdev->dev,
 			 "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
-- 
1.8.3.1
