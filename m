From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 03/12] qed: Rename some ll2 related defines
Date: Sun, 2 Jul 2017 10:29:23 +0300
Message-ID: <1498980572-29519-4-git-send-email-Michal.Kalderon@cavium.com>
References: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:6304
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750771AbdGBHbz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Jul 2017 03:31:55 -0400
In-Reply-To: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make some names more generic as they will be used by iWARP too.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 29 ++++++++++++++---------------
 include/linux/qed/qed_ll2_if.h            |  2 +-
 3 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 22e1171..fd8cd5e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -779,7 +779,7 @@ static inline u8 qed_concrete_to_sw_fid(struct qed_dev *cdev,
 }
 
 #define PURE_LB_TC 8
-#define OOO_LB_TC 9
+#define PKT_LB_TC 9
 
 int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate);
 void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index be66f19..e235fb2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -309,7 +309,7 @@ static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 		list_del(&p_pkt->list_entry);
 		b_last_packet = list_empty(&p_tx->active_descq);
 		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
-		if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_ISCSI_OOO) {
+		if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_OOO) {
 			struct qed_ooo_buffer *p_buffer;
 
 			p_buffer = (struct qed_ooo_buffer *)p_pkt->cookie;
@@ -532,7 +532,7 @@ static void qed_ll2_rxq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 
 		list_move_tail(&p_pkt->list_entry, &p_rx->free_descq);
 
-		if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_ISCSI_OOO) {
+		if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_OOO) {
 			struct qed_ooo_buffer *p_buffer;
 
 			p_buffer = (struct qed_ooo_buffer *)p_pkt->cookie;
@@ -893,8 +893,7 @@ static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->drop_ttl0_flg = p_ll2_conn->input.rx_drop_ttl0_flg;
 	p_ramrod->inner_vlan_removal_en = p_ll2_conn->input.rx_vlan_removal_en;
 	p_ramrod->queue_id = p_ll2_conn->queue_id;
-	p_ramrod->main_func_queue = (conn_type == QED_LL2_TYPE_ISCSI_OOO) ? 0
-									  : 1;
+	p_ramrod->main_func_queue = (conn_type == QED_LL2_TYPE_OOO) ? 0 : 1;
 
 	if ((IS_MF_DEFAULT(p_hwfn) || IS_MF_SI(p_hwfn)) &&
 	    p_ramrod->main_func_queue && (conn_type != QED_LL2_TYPE_ROCE)) {
@@ -924,7 +923,7 @@ static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
 	if (!QED_LL2_TX_REGISTERED(p_ll2_conn))
 		return 0;
 
-	if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_ISCSI_OOO)
+	if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_OOO)
 		p_ll2_conn->tx_stats_en = 0;
 	else
 		p_ll2_conn->tx_stats_en = 1;
@@ -955,10 +954,10 @@ static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->pbl_size = cpu_to_le16(pbl_size);
 
 	switch (p_ll2_conn->input.tx_tc) {
-	case LB_TC:
+	case PURE_LB_TC:
 		pq_id = qed_get_cm_pq_idx(p_hwfn, PQ_FLAGS_LB);
 		break;
-	case OOO_LB_TC:
+	case PKT_LB_TC:
 		pq_id = qed_get_cm_pq_idx(p_hwfn, PQ_FLAGS_OOO);
 		break;
 	default:
@@ -973,7 +972,7 @@ static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
 		p_ramrod->conn_type = PROTOCOLID_FCOE;
 		break;
 	case QED_LL2_TYPE_ISCSI:
-	case QED_LL2_TYPE_ISCSI_OOO:
+	case QED_LL2_TYPE_OOO:
 		p_ramrod->conn_type = PROTOCOLID_ISCSI;
 		break;
 	case QED_LL2_TYPE_ROCE:
@@ -1142,7 +1141,7 @@ static int qed_ll2_acquire_connection_tx(struct qed_hwfn *p_hwfn,
 	u16 buf_idx;
 	int rc = 0;
 
-	if (p_ll2_info->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
+	if (p_ll2_info->input.conn_type != QED_LL2_TYPE_OOO)
 		return rc;
 
 	/* Correct number of requested OOO buffers if needed */
@@ -1280,7 +1279,7 @@ int qed_ll2_acquire_connection(void *cxt, struct qed_ll2_acquire_data *data)
 		goto q_allocate_fail;
 
 	/* Register callbacks for the Rx/Tx queues */
-	if (data->input.conn_type == QED_LL2_TYPE_ISCSI_OOO) {
+	if (data->input.conn_type == QED_LL2_TYPE_OOO) {
 		comp_rx_cb = qed_ll2_lb_rxq_completion;
 		comp_tx_cb = qed_ll2_lb_txq_completion;
 	} else {
@@ -1339,7 +1338,7 @@ static int qed_ll2_establish_connection_rx(struct qed_hwfn *p_hwfn,
 qed_ll2_establish_connection_ooo(struct qed_hwfn *p_hwfn,
 				 struct qed_ll2_info *p_ll2_conn)
 {
-	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
+	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_OOO)
 		return;
 
 	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
@@ -1794,7 +1793,7 @@ int qed_ll2_terminate_connection(void *cxt, u8 connection_handle)
 		qed_ll2_rxq_flush(p_hwfn, connection_handle);
 	}
 
-	if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_ISCSI_OOO)
+	if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_OOO)
 		qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
 
 	if (p_ll2_conn->input.conn_type == QED_LL2_TYPE_FCOE) {
@@ -1816,7 +1815,7 @@ static void qed_ll2_release_connection_ooo(struct qed_hwfn *p_hwfn,
 {
 	struct qed_ooo_buffer *p_buffer;
 
-	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_ISCSI_OOO)
+	if (p_ll2_conn->input.conn_type != QED_LL2_TYPE_OOO)
 		return;
 
 	qed_ooo_release_all_isles(p_hwfn, p_hwfn->p_ooo_info);
@@ -2063,7 +2062,7 @@ static void qed_ll2_set_conn_data(struct qed_dev *cdev,
 	ll2_cbs.cookie = QED_LEADING_HWFN(cdev);
 
 	if (lb) {
-		data->input.tx_tc = OOO_LB_TC;
+		data->input.tx_tc = PKT_LB_TC;
 		data->input.tx_dest = QED_LL2_TX_DEST_LB;
 	} else {
 		data->input.tx_tc = 0;
@@ -2080,7 +2079,7 @@ static int qed_ll2_start_ooo(struct qed_dev *cdev,
 	int rc;
 
 	qed_ll2_set_conn_data(cdev, &data, params,
-			      QED_LL2_TYPE_ISCSI_OOO, handle, true);
+			      QED_LL2_TYPE_OOO, handle, true);
 
 	rc = qed_ll2_acquire_connection(hwfn, &data);
 	if (rc) {
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index 5958b45e..c9c56bc 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -47,7 +47,7 @@ enum qed_ll2_conn_type {
 	QED_LL2_TYPE_FCOE,
 	QED_LL2_TYPE_ISCSI,
 	QED_LL2_TYPE_TEST,
-	QED_LL2_TYPE_ISCSI_OOO,
+	QED_LL2_TYPE_OOO,
 	QED_LL2_TYPE_RESERVED2,
 	QED_LL2_TYPE_ROCE,
 	QED_LL2_TYPE_RESERVED3,
-- 
1.8.3.1
