From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/14] i40e: assign correct vector to VF
Date: Tue, 22 Oct 2013 07:22:26 -0700
Message-ID: <1382451757-9817-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	sergei.shtylyov@cogentembedded.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48026 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393Ab3JVOWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:51 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Correct math error when assigning MSI-X vectors to VFs. The vectors-per-vf
value reported by the hardware already conveniently reports one less than the
actual value.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2:
 - Removed unnecessary parenthesis
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8967e58..35f4909 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -251,7 +251,7 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_idx,
 		reg_idx = I40E_VPINT_LNKLST0(vf->vf_id);
 	else
 		reg_idx = I40E_VPINT_LNKLSTN(
-			    ((pf->hw.func_caps.num_msix_vectors_vf - 1)
+					   (pf->hw.func_caps.num_msix_vectors_vf
 					      * vf->vf_id) + (vector_id - 1));
 
 	if (vecmap->rxq_map == 0 && vecmap->txq_map == 0) {
-- 
1.8.3.1
