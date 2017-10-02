From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Fix a potential NULL pointer dereference
Date: Mon,  2 Oct 2017 12:48:40 -0700
Message-ID: <20171002194852.71970-4-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39749 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751692AbdJBTtW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:22 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

If 'kzalloc()' fails, a NULL pointer will be dereferenced.
Return an error code (-ENOMEM) instead.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index e6b95e1e1a33..9e3667fc7f6a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -423,6 +423,9 @@ static int i40e_config_iwarp_qvlist(struct i40e_vf *vf,
 	       (sizeof(struct virtchnl_iwarp_qv_info) *
 						(qvlist_info->num_vectors - 1));
 	vf->qvlist_info = kzalloc(size, GFP_KERNEL);
+	if (!vf->qvlist_info)
+		return -ENOMEM;
+
 	vf->qvlist_info->num_vectors = qvlist_info->num_vectors;
 
 	msix_vf = pf->hw.func_caps.num_msix_vectors_vf;
-- 
2.14.2
