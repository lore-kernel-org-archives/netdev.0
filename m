From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] i40e: don't disable PF LB when disabling VFs
Date: Sat, 28 Feb 2015 03:29:38 -0800
Message-ID: <1425122989-354-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49619 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbbB1L35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:57 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Since we now have functionality to enable and disable PF loopback at
runtime, don't try to do it automatically. Removing this call also gets
rid of a bogus error message when removing the PF module with VFs
enabled.

Change-ID: Ic38652d8a3b9498d96113bfaa5ea7bad050862e9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 493335c..910c45e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -832,7 +832,6 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
 			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
 		}
-		i40e_disable_pf_switch_lb(pf);
 	} else {
 		dev_warn(&pf->pdev->dev,
 			 "unable to disable SR-IOV because VFs are assigned.\n");
-- 
1.9.3
