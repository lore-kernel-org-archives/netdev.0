From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] i40e: using for_each_set_bit to simplify the code
Date: Mon, 23 Sep 2013 11:39:37 +0800
Message-ID: <CAPgLHd8MsmVDONTENFNcRNf=7xWPGE5LJD7Z+0oNS5Lkscr4Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	shannon.nelson@intel.com, mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:51346 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab3IWDjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 23:39:39 -0400
Received: by mail-bk0-f47.google.com with SMTP id mx12so943267bkb.34
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 20:39:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using for_each_set_bit() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 64 ++++------------------
 1 file changed, 12 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8967e58..84d7675 100644
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
@@ -1291,27 +1285,21 @@ static int i40e_vc_config_irq_map_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
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
@@ -1356,31 +1344,23 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
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
@@ -1389,29 +1369,23 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
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
@@ -1455,31 +1429,23 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
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
@@ -1488,29 +1454,23 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
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
