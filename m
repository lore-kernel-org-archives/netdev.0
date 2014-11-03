From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] i40e: better wording for resource tracking errors
Date: Mon,  3 Nov 2014 06:56:36 -0800
Message-ID: <1415026599-16232-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44867 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694AbaKCO4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:55 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Tweak and homogenize the error reporting for get_lump() resource
tracking errors.

Change-ID: I11330161cc6ad8d04371c499c63071c816171c3b
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 83fee7f..6a481bf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7957,8 +7957,8 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 						 vsi->num_q_vectors, vsi->idx);
 	if (vsi->base_vector < 0) {
 		dev_info(&pf->pdev->dev,
-			 "failed to get queue tracking for VSI %d, err=%d\n",
-			 vsi->seid, vsi->base_vector);
+			 "failed to get tracking for %d vectors for VSI %d, err=%d\n",
+			 vsi->num_q_vectors, vsi->seid, vsi->base_vector);
 		i40e_vsi_free_q_vectors(vsi);
 		ret = -ENOENT;
 		goto vector_setup_out;
@@ -7994,8 +7994,9 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 
 	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs, vsi->idx);
 	if (ret < 0) {
-		dev_info(&pf->pdev->dev, "VSI %d get_lump failed %d\n",
-			 vsi->seid, ret);
+		dev_info(&pf->pdev->dev,
+			 "failed to get tracking for %d queues for VSI %d err=%d\n",
+			 vsi->alloc_queue_pairs, vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
@@ -8124,8 +8125,9 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs,
 				vsi->idx);
 	if (ret < 0) {
-		dev_info(&pf->pdev->dev, "VSI %d get_lump failed %d\n",
-			 vsi->seid, ret);
+		dev_info(&pf->pdev->dev,
+			 "failed to get tracking for %d queues for VSI %d err=%d\n",
+			 vsi->alloc_queue_pairs, vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
-- 
1.9.3
