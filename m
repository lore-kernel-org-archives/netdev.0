From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/14] i40e: make string references to q be queue
Date: Fri, 14 Mar 2014 16:34:26 -0700
Message-ID: <1394840075-6851-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29252 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756255AbaCNXfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:07 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This cleans up strings for consistency, q is replaced with queue.

Change-ID: Ia5f9dfae9af261f4c24485854264e02363729cf3
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a3f122e..acf0b20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2582,7 +2582,7 @@ static void i40e_configure_msi_and_legacy(struct i40e_vsi *vsi)
 	/* FIRSTQ_INDX = 0, FIRSTQ_TYPE = 0 (rx) */
 	wr32(hw, I40E_PFINT_LNKLST0, 0);
 
-	/* Associate the queue pair to the vector and enable the q int */
+	/* Associate the queue pair to the vector and enable the queue int */
 	val = I40E_QINT_RQCTL_CAUSE_ENA_MASK		      |
 	      (I40E_RX_ITR << I40E_QINT_RQCTL_ITR_INDX_SHIFT) |
 	      (I40E_QUEUE_TYPE_TX << I40E_QINT_TQCTL_NEXTQ_TYPE_SHIFT);
@@ -5442,7 +5442,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK)
 				>> I40E_GL_MDET_TX_QUEUE_SHIFT;
 		dev_info(&pf->pdev->dev,
-			 "Malicious Driver Detection TX event 0x%02x on q %d of function 0x%02x\n",
+			 "Malicious Driver Detection event 0x%02x on TX queue %d of function 0x%02x\n",
 			 event, queue, func);
 		wr32(hw, I40E_GL_MDET_TX, 0xffffffff);
 		mdd_detected = true;
@@ -5456,7 +5456,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK)
 				>> I40E_GL_MDET_RX_QUEUE_SHIFT;
 		dev_info(&pf->pdev->dev,
-			 "Malicious Driver Detection RX event 0x%02x on q %d of function 0x%02x\n",
+			 "Malicious Driver Detection event 0x%02x on RX queue %d of function 0x%02x\n",
 			 event, queue, func);
 		wr32(hw, I40E_GL_MDET_RX, 0xffffffff);
 		mdd_detected = true;
@@ -6882,8 +6882,7 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 	}
 
 	if (vsi->base_vector) {
-		dev_info(&pf->pdev->dev,
-			 "VSI %d has non-zero base vector %d\n",
+		dev_info(&pf->pdev->dev, "VSI %d has non-zero base vector %d\n",
 			 vsi->seid, vsi->base_vector);
 		return -EEXIST;
 	}
@@ -6902,7 +6901,7 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 						 vsi->num_q_vectors, vsi->idx);
 	if (vsi->base_vector < 0) {
 		dev_info(&pf->pdev->dev,
-			 "failed to get q tracking for VSI %d, err=%d\n",
+			 "failed to get queue tracking for VSI %d, err=%d\n",
 			 vsi->seid, vsi->base_vector);
 		i40e_vsi_free_q_vectors(vsi);
 		ret = -ENOENT;
-- 
1.8.3.1
