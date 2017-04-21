From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 1/5] qed: Cleanup DCBx unnecessary parameters.
Date: Thu, 20 Apr 2017 22:31:16 -0700
Message-ID: <20170421053120.12980-2-sudarsana.kalluru@cavium.com>
References: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0058.outbound.protection.outlook.com ([104.47.36.58]:42496
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035352AbdDUFb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:31:57 -0400
In-Reply-To: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 38 ++++++++++++------------------
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  2 +-
 3 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 2fc1fde..9b4580b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -271,8 +271,8 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 		     struct dcbx_app_priority_entry *p_tbl,
 		     u32 pri_tc_tbl, int count, u8 dcbx_version)
 {
-	u8 tc, priority_map;
 	enum dcbx_protocol_type type;
+	u8 tc, priority_map;
 	bool enable, ieee;
 	u16 protocol_id;
 	int priority;
@@ -613,8 +613,7 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 }
 
 static void
-qed_dcbx_get_local_params(struct qed_hwfn *p_hwfn,
-			  struct qed_ptt *p_ptt, struct qed_dcbx_get *params)
+qed_dcbx_get_local_params(struct qed_hwfn *p_hwfn, struct qed_dcbx_get *params)
 {
 	struct dcbx_features *p_feat;
 
@@ -626,8 +625,7 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 }
 
 static void
-qed_dcbx_get_remote_params(struct qed_hwfn *p_hwfn,
-			   struct qed_ptt *p_ptt, struct qed_dcbx_get *params)
+qed_dcbx_get_remote_params(struct qed_hwfn *p_hwfn, struct qed_dcbx_get *params)
 {
 	struct dcbx_features *p_feat;
 
@@ -640,7 +638,6 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 
 static void
 qed_dcbx_get_operational_params(struct qed_hwfn *p_hwfn,
-				struct qed_ptt *p_ptt,
 				struct qed_dcbx_get *params)
 {
 	struct qed_dcbx_operational_params *p_operational;
@@ -690,7 +687,6 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 
 static void
 qed_dcbx_get_local_lldp_params(struct qed_hwfn *p_hwfn,
-			       struct qed_ptt *p_ptt,
 			       struct qed_dcbx_get *params)
 {
 	struct lldp_config_params_s *p_local;
@@ -705,7 +701,6 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 
 static void
 qed_dcbx_get_remote_lldp_params(struct qed_hwfn *p_hwfn,
-				struct qed_ptt *p_ptt,
 				struct qed_dcbx_get *params)
 {
 	struct lldp_status_params_s *p_remote;
@@ -719,25 +714,24 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 }
 
 static int
-qed_dcbx_get_params(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-		    struct qed_dcbx_get *p_params,
+qed_dcbx_get_params(struct qed_hwfn *p_hwfn, struct qed_dcbx_get *p_params,
 		    enum qed_mib_read_type type)
 {
 	switch (type) {
 	case QED_DCBX_REMOTE_MIB:
-		qed_dcbx_get_remote_params(p_hwfn, p_ptt, p_params);
+		qed_dcbx_get_remote_params(p_hwfn, p_params);
 		break;
 	case QED_DCBX_LOCAL_MIB:
-		qed_dcbx_get_local_params(p_hwfn, p_ptt, p_params);
+		qed_dcbx_get_local_params(p_hwfn, p_params);
 		break;
 	case QED_DCBX_OPERATIONAL_MIB:
-		qed_dcbx_get_operational_params(p_hwfn, p_ptt, p_params);
+		qed_dcbx_get_operational_params(p_hwfn, p_params);
 		break;
 	case QED_DCBX_REMOTE_LLDP_MIB:
-		qed_dcbx_get_remote_lldp_params(p_hwfn, p_ptt, p_params);
+		qed_dcbx_get_remote_lldp_params(p_hwfn, p_params);
 		break;
 	case QED_DCBX_LOCAL_LLDP_MIB:
-		qed_dcbx_get_local_lldp_params(p_hwfn, p_ptt, p_params);
+		qed_dcbx_get_local_lldp_params(p_hwfn, p_params);
 		break;
 	default:
 		DP_ERR(p_hwfn, "MIB read err, unknown mib type %d\n", type);
@@ -895,7 +889,8 @@ void qed_dcbx_aen(struct qed_hwfn *hwfn, u32 mib_type)
 			qed_sp_pf_update(p_hwfn);
 		}
 	}
-	qed_dcbx_get_params(p_hwfn, p_ptt, &p_hwfn->p_dcbx_info->get, type);
+
+	qed_dcbx_get_params(p_hwfn, &p_hwfn->p_dcbx_info->get, type);
 	qed_dcbx_aen(p_hwfn, type);
 
 	return rc;
@@ -903,17 +898,14 @@ void qed_dcbx_aen(struct qed_hwfn *hwfn, u32 mib_type)
 
 int qed_dcbx_info_alloc(struct qed_hwfn *p_hwfn)
 {
-	int rc = 0;
-
 	p_hwfn->p_dcbx_info = kzalloc(sizeof(*p_hwfn->p_dcbx_info), GFP_KERNEL);
 	if (!p_hwfn->p_dcbx_info)
-		rc = -ENOMEM;
+		return -ENOMEM;
 
-	return rc;
+	return 0;
 }
 
-void qed_dcbx_info_free(struct qed_hwfn *p_hwfn,
-			struct qed_dcbx_info *p_dcbx_info)
+void qed_dcbx_info_free(struct qed_hwfn *p_hwfn)
 {
 	kfree(p_hwfn->p_dcbx_info);
 }
@@ -985,7 +977,7 @@ static int qed_dcbx_query_params(struct qed_hwfn *p_hwfn,
 	if (rc)
 		goto out;
 
-	rc = qed_dcbx_get_params(p_hwfn, p_ptt, p_get, type);
+	rc = qed_dcbx_get_params(p_hwfn, p_get, type);
 
 out:
 	qed_ptt_release(p_hwfn, p_ptt);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
index 2eb988f..414e262 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
@@ -119,7 +119,7 @@ int qed_dcbx_config_params(struct qed_hwfn *,
 			  struct qed_ptt *, enum qed_mib_read_type);
 
 int qed_dcbx_info_alloc(struct qed_hwfn *p_hwfn);
-void qed_dcbx_info_free(struct qed_hwfn *, struct qed_dcbx_info *);
+void qed_dcbx_info_free(struct qed_hwfn *p_hwfn);
 void qed_dcbx_set_pf_update_params(struct qed_dcbx_results *p_src,
 				   struct pf_update_ramrod_data *p_dest);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index fad7319..6d24308 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -183,7 +183,7 @@ void qed_resc_free(struct qed_dev *cdev)
 		}
 		qed_iov_free(p_hwfn);
 		qed_dmae_info_free(p_hwfn);
-		qed_dcbx_info_free(p_hwfn, p_hwfn->p_dcbx_info);
+		qed_dcbx_info_free(p_hwfn);
 	}
 }
 
-- 
1.8.3.1
