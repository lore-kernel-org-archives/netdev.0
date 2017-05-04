From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net v2 1/3] qed*: Fix possible overflow for status block id field.
Date: Thu, 4 May 2017 08:15:03 -0700
Message-ID: <20170504151505.4407-2-sudarsana.kalluru@cavium.com>
References: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0046.outbound.protection.outlook.com ([104.47.34.46]:56061
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754975AbdEDPPb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 11:15:31 -0400
In-Reply-To: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Value for status block id could be more than 256 in 100G mode, need to
update its data type from u8 to u16.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 8 ++++----
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h   | 4 ++--
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 2 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 5 ++---
 include/linux/qed/qed_if.h                      | 2 +-
 5 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 5f31140..5c6874a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -3586,7 +3586,7 @@ static int qed_set_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 }
 
 int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u8 qid, u16 sb_id)
+			 u16 coalesce, u16 qid, u16 sb_id)
 {
 	struct ustorm_eth_queue_zone eth_qzone;
 	u8 timeset, timer_res;
@@ -3607,7 +3607,7 @@ int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 	timeset = (u8)(coalesce >> timer_res);
 
-	rc = qed_fw_l2_queue(p_hwfn, (u16)qid, &fw_qid);
+	rc = qed_fw_l2_queue(p_hwfn, qid, &fw_qid);
 	if (rc)
 		return rc;
 
@@ -3628,7 +3628,7 @@ int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 }
 
 int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u8 qid, u16 sb_id)
+			 u16 coalesce, u16 qid, u16 sb_id)
 {
 	struct xstorm_eth_queue_zone eth_qzone;
 	u8 timeset, timer_res;
@@ -3649,7 +3649,7 @@ int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 	timeset = (u8)(coalesce >> timer_res);
 
-	rc = qed_fw_l2_queue(p_hwfn, (u16)qid, &fw_qid);
+	rc = qed_fw_l2_queue(p_hwfn, qid, &fw_qid);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index cefe3ee..12d16c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -454,7 +454,7 @@ int qed_final_cleanup(struct qed_hwfn *p_hwfn,
  * @return int
  */
 int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u8 qid, u16 sb_id);
+			 u16 coalesce, u16 qid, u16 sb_id);
 
 /**
  * @brief qed_set_txq_coalesce - Configure coalesce parameters for a Tx queue
@@ -471,7 +471,7 @@ int qed_set_rxq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
  * @return int
  */
 int qed_set_txq_coalesce(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			 u16 coalesce, u8 qid, u16 sb_id);
+			 u16 coalesce, u16 qid, u16 sb_id);
 
 const char *qed_hw_get_resc_name(enum qed_resources res_id);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 59992cf..a5eef1a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1521,7 +1521,7 @@ static void qed_get_coalesce(struct qed_dev *cdev, u16 *rx_coal, u16 *tx_coal)
 }
 
 static int qed_set_coalesce(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
-			    u8 qid, u16 sb_id)
+			    u16 qid, u16 sb_id)
 {
 	struct qed_hwfn *hwfn;
 	struct qed_ptt *ptt;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 4dcfe96..b22753c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -706,8 +706,7 @@ static int qede_set_coalesce(struct net_device *dev,
 {
 	struct qede_dev *edev = netdev_priv(dev);
 	int i, rc = 0;
-	u16 rxc, txc;
-	u8 sb_id;
+	u16 rxc, txc, sb_id;
 
 	if (!netif_running(dev)) {
 		DP_INFO(edev, "Interface is down\n");
@@ -729,7 +728,7 @@ static int qede_set_coalesce(struct net_device *dev,
 	for_each_queue(i) {
 		sb_id = edev->fp_array[i].sb_info->igu_sb_id;
 		rc = edev->ops->common->set_coalesce(edev->cdev, rxc, txc,
-						     (u8)i, sb_id);
+						     (u16)i, sb_id);
 		if (rc) {
 			DP_INFO(edev, "Set coalesce error, rc = %d\n", rc);
 			return rc;
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 5544d7b..c70ac13 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -635,7 +635,7 @@ struct qed_common_ops {
  * @return 0 on success, error otherwise.
  */
 	int (*set_coalesce)(struct qed_dev *cdev, u16 rx_coal, u16 tx_coal,
-			    u8 qid, u16 sb_id);
+			    u16 qid, u16 sb_id);
 
 /**
  * @brief set_led - Configure LED mode
-- 
1.8.3.1
