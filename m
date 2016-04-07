From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: Move HW flush
Date: Wed,  6 Apr 2016 20:29:28 -0700
Message-ID: <1459999779-22254-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47670 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbcDGD3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:43 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch moves the HW flush routine to the end of the reset flow,
after the completion of writing to the device VFLR registers- the
benefit is to avoid problems in the passthrough routines.

Change-ID: Ieb56866f21895e6c1fc514b7328c3df79807a57c
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9924503..f2a9c14 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -941,6 +941,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	reg_idx = (hw->func_caps.vf_base_id + vf->vf_id) / 32;
 	bit_idx = (hw->func_caps.vf_base_id + vf->vf_id) % 32;
 	wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
+	i40e_flush(hw);
 
 	if (i40e_quiesce_vf_pci(vf))
 		dev_err(&pf->pdev->dev, "VF %d PCI transactions stuck\n",
-- 
2.5.5
