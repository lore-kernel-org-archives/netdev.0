From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/14] i40e: use pf_id for pf function id in qtx_ctl
Date: Tue, 22 Oct 2013 07:22:36 -0700
Message-ID: <1382451757-9817-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56407 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753547Ab3JVOW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:56 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Simplify code by using an already existing variable.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 727d14d..d889342 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2174,8 +2174,8 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 
 	/* Now associate this queue with this PCI function */
 	qtx_ctl = I40E_QTX_CTL_PF_QUEUE;
-	qtx_ctl |= ((hw->hmc.hmc_fn_id << I40E_QTX_CTL_PF_INDX_SHIFT)
-						& I40E_QTX_CTL_PF_INDX_MASK);
+	qtx_ctl |= ((hw->pf_id << I40E_QTX_CTL_PF_INDX_SHIFT) &
+		    I40E_QTX_CTL_PF_INDX_MASK);
 	wr32(hw, I40E_QTX_CTL(pf_q), qtx_ctl);
 	i40e_flush(hw);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 35f4909..0759698 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -383,7 +383,7 @@ static int i40e_config_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_idx,
 
 	/* associate this queue with the PCI VF function */
 	qtx_ctl = I40E_QTX_CTL_VF_QUEUE;
-	qtx_ctl |= ((hw->hmc.hmc_fn_id << I40E_QTX_CTL_PF_INDX_SHIFT)
+	qtx_ctl |= ((hw->pf_id << I40E_QTX_CTL_PF_INDX_SHIFT)
 		    & I40E_QTX_CTL_PF_INDX_MASK);
 	qtx_ctl |= (((vf->vf_id + hw->func_caps.vf_base_id)
 		     << I40E_QTX_CTL_VFVM_INDX_SHIFT)
-- 
1.8.3.1
