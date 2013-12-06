From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: allow one more vector for VFs
Date: Fri,  6 Dec 2013 00:06:19 -0800
Message-ID: <1386317188-13944-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab3LFIGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:36 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The number of vectors per VF as reported by the hardware does not
include vector 0, so we need to account for this when checking to
see if the VF is configuring a valid vector.

Change-Id: I051d8bebae8f4722239f5a3fa5e1de4cf0f4e817
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0759698..d98cc9b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -70,7 +70,7 @@ static inline bool i40e_vc_isvalid_vector_id(struct i40e_vf *vf, u8 vector_id)
 {
 	struct i40e_pf *pf = vf->pf;
 
-	return vector_id < pf->hw.func_caps.num_msix_vectors_vf;
+	return vector_id <= pf->hw.func_caps.num_msix_vectors_vf;
 }
 
 /***********************vf resource mgmt routines*****************/
-- 
1.8.3.1
