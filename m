From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 02/17] i40e: using for_each_set_bit to simplify the code
Date: Fri,  3 Jan 2014 21:56:30 -0800
Message-ID: <1388815005-23166-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31987 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987AbaADF4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:56:51 -0500
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using for_each_set_bit() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 64 ++++------------------
 1 file changed, 12 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 68e1f8e..1ea0886 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -260,23 +260,17 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_idx,
 		goto irq_list_done;
 	}
 	tempmap = vecmap->rxq_map;
-	vsi_queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (vsi_queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(vsi_queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		linklistmap |= (1 <<
 				(I40E_VIRTCHNL_SUPPORTED_QTYPES *
 				 vsi_queue_id));
-		vsi_queue_id =
-		    find_next_bit(&tempmap, I40E_MAX_VSI_QP, vsi_queue_id + 1);
 	}
 
 	tempmap = vecmap->txq_map;
-	vsi_queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (vsi_queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(vsi_queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		linklistmap |= (1 <<
 				(I40E_VIRTCHNL_SUPPORTED_QTYPES * vsi_queue_id
 				 + 1));
-		vsi_queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					     vsi_queue_id + 1);
 	}
 
 	next_q = find_first_bit(&linklistmap,
@@ -1293,27 +1287,21 @@ static int i40e_vc_config_irq_map_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		/* lookout for the invalid queue index */
 		tempmap = map->rxq_map;
-		vsi_queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-		while (vsi_queue_id < I40E_MAX_VSI_QP) {
+		for_each_set_bit(vsi_queue_id, &tempmap, I40E_MAX_VSI_QP) {
 			if (!i40e_vc_isvalid_queue_id(vf, vsi_id,
 						      vsi_queue_id)) {
 				aq_ret = I40E_ERR_PARAM;
 				goto error_param;
 			}
-			vsi_queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-						     vsi_queue_id + 1);
 		}
 
 		tempmap = map->txq_map;
-		vsi_queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-		while (vsi_queue_id < I40E_MAX_VSI_QP) {
+		for_each_set_bit(vsi_queue_id, &tempmap, I40E_MAX_VSI_QP) {
 			if (!i40e_vc_isvalid_queue_id(vf, vsi_id,
 						      vsi_queue_id)) {
 				aq_ret = I40E_ERR_PARAM;
 				goto error_param;
 			}
-			vsi_queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-						     vsi_queue_id + 1);
 		}
 
 		i40e_config_irq_link_list(vf, vsi_id, map);
@@ -1358,31 +1346,23 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 
 	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
 			aq_ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
 		i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 				       I40E_QUEUE_CTRL_ENABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
 			aq_ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
 		i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 				       I40E_QUEUE_CTRL_ENABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	/* Poll the status register to make sure that the
@@ -1391,29 +1371,23 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	udelay(10);
 
 	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					   I40E_QUEUE_CTRL_ENABLECHECK)) {
 			dev_err(&pf->pdev->dev,
 				"Queue control check failed on RX queue %d of VSI %d VF %d\n",
 				queue_id, vsi_id, vf->vf_id);
 		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					   I40E_QUEUE_CTRL_ENABLECHECK)) {
 			dev_err(&pf->pdev->dev,
 				"Queue control check failed on TX queue %d of VSI %d VF %d\n",
 				queue_id, vsi_id, vf->vf_id);
 		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 error_param:
@@ -1457,31 +1431,23 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 
 	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
 			aq_ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
 		i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 				       I40E_QUEUE_CTRL_DISABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
 			aq_ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
 		i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 				       I40E_QUEUE_CTRL_DISABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	/* Poll the status register to make sure that the
@@ -1490,29 +1456,23 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	udelay(10);
 
 	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					   I40E_QUEUE_CTRL_DISABLECHECK)) {
 			dev_err(&pf->pdev->dev,
 				"Queue control check failed on RX queue %d of VSI %d VF %d\n",
 				queue_id, vsi_id, vf->vf_id);
 		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
+	for_each_set_bit(queue_id, &tempmap, I40E_MAX_VSI_QP) {
 		if (i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					   I40E_QUEUE_CTRL_DISABLECHECK)) {
 			dev_err(&pf->pdev->dev,
 				"Queue control check failed on TX queue %d of VSI %d VF %d\n",
 				queue_id, vsi_id, vf->vf_id);
 		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
 	}
 
 error_param:
-- 
1.8.3.1
