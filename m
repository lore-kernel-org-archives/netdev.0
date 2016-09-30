From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 1/2] qed: mark symbols static where possible
Date: Fri, 30 Sep 2016 15:56:29 +0800
Message-ID: <1475222189-19092-1-git-send-email-baoyou.xie@linaro.org>
Cc: everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33119 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbcI3H4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 03:56:45 -0400
Received: by mail-pf0-f176.google.com with SMTP id 21so37851296pfy.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 00:56:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 12 warnings when building kernel with W=1:
drivers/net/ethernet/qlogic/qed/qed_cxt.c:346:6: warning: no previous prototype for 'qed_cxt_set_srq_count' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:353:5: warning: no previous prototype for 'qed_cxt_get_srq_count' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:389:5: warning: no previous prototype for 'qed_cxt_get_proto_cid_start' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:395:5: warning: no previous prototype for 'qed_cxt_get_proto_tid_count' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_cxt.c:1801:6: warning: no previous prototype for 'qed_rdma_set_pf_params' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:4031:17: warning: no previous prototype for 'qed_mcp_trace_dump' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:4133:17: warning: no previous prototype for 'qed_reg_fifo_dump' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:4195:17: warning: no previous prototype for 'qed_igu_fifo_dump' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:4258:17: warning: no previous prototype for 'qed_protection_override_dump' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:6342:17: warning: no previous prototype for 'qed_print_idle_chk_results_wrapper' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:6416:17: warning: no previous prototype for 'format_feature' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_debug.c:6483:17: warning: no previous prototype for 'qed_dbg_dump' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
So this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c   | 16 ++++-----
 drivers/net/ethernet/qlogic/qed/qed_debug.c | 51 +++++++++++++++--------------
 2 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index dd579b2..d7e9b14 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -343,14 +343,14 @@ static struct qed_tid_seg *qed_cxt_tid_seg_info(struct qed_hwfn *p_hwfn,
 	return NULL;
 }
 
-void qed_cxt_set_srq_count(struct qed_hwfn *p_hwfn, u32 num_srqs)
+static void qed_cxt_set_srq_count(struct qed_hwfn *p_hwfn, u32 num_srqs)
 {
 	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
 
 	p_mgr->srq_count = num_srqs;
 }
 
-u32 qed_cxt_get_srq_count(struct qed_hwfn *p_hwfn)
+static u32 qed_cxt_get_srq_count(struct qed_hwfn *p_hwfn)
 {
 	struct qed_cxt_mngr *p_mgr = p_hwfn->p_cxt_mngr;
 
@@ -386,14 +386,14 @@ u32 qed_cxt_get_proto_cid_count(struct qed_hwfn *p_hwfn,
 	return p_hwfn->p_cxt_mngr->conn_cfg[type].cid_count;
 }
 
-u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
-				enum protocol_type type)
+static u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
+				       enum protocol_type type)
 {
 	return p_hwfn->p_cxt_mngr->acquired[type].start_cid;
 }
 
-u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
-				enum protocol_type type)
+static u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
+				       enum protocol_type type)
 {
 	u32 cnt = 0;
 	int i;
@@ -1798,8 +1798,8 @@ int qed_cxt_get_cid_info(struct qed_hwfn *p_hwfn, struct qed_cxt_info *p_info)
 	return 0;
 }
 
-void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
-			    struct qed_rdma_pf_params *p_params)
+static void qed_rdma_set_pf_params(struct qed_hwfn *p_hwfn,
+				   struct qed_rdma_pf_params *p_params)
 {
 	u32 num_cons, num_tasks, num_qps, num_mrs, num_srqs;
 	enum protocol_type proto;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_debug.c b/drivers/net/ethernet/qlogic/qed/qed_debug.c
index 88e7d5b..6f1d54e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_debug.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_debug.c
@@ -4028,10 +4028,10 @@ static enum dbg_status qed_mcp_trace_read_meta(struct qed_hwfn *p_hwfn,
 }
 
 /* Dump MCP Trace */
-enum dbg_status qed_mcp_trace_dump(struct qed_hwfn *p_hwfn,
-				   struct qed_ptt *p_ptt,
-				   u32 *dump_buf,
-				   bool dump, u32 *num_dumped_dwords)
+static enum dbg_status qed_mcp_trace_dump(struct qed_hwfn *p_hwfn,
+					  struct qed_ptt *p_ptt,
+					  u32 *dump_buf,
+					  bool dump, u32 *num_dumped_dwords)
 {
 	u32 trace_data_grc_addr, trace_data_size_bytes, trace_data_size_dwords;
 	u32 trace_meta_size_dwords, running_bundle_id, offset = 0;
@@ -4130,10 +4130,10 @@ enum dbg_status qed_mcp_trace_dump(struct qed_hwfn *p_hwfn,
 }
 
 /* Dump GRC FIFO */
-enum dbg_status qed_reg_fifo_dump(struct qed_hwfn *p_hwfn,
-				  struct qed_ptt *p_ptt,
-				  u32 *dump_buf,
-				  bool dump, u32 *num_dumped_dwords)
+static enum dbg_status qed_reg_fifo_dump(struct qed_hwfn *p_hwfn,
+					 struct qed_ptt *p_ptt,
+					 u32 *dump_buf,
+					 bool dump, u32 *num_dumped_dwords)
 {
 	u32 offset = 0, dwords_read, size_param_offset;
 	bool fifo_has_data;
@@ -4192,10 +4192,10 @@ enum dbg_status qed_reg_fifo_dump(struct qed_hwfn *p_hwfn,
 }
 
 /* Dump IGU FIFO */
-enum dbg_status qed_igu_fifo_dump(struct qed_hwfn *p_hwfn,
-				  struct qed_ptt *p_ptt,
-				  u32 *dump_buf,
-				  bool dump, u32 *num_dumped_dwords)
+static enum dbg_status qed_igu_fifo_dump(struct qed_hwfn *p_hwfn,
+					 struct qed_ptt *p_ptt,
+					 u32 *dump_buf,
+					 bool dump, u32 *num_dumped_dwords)
 {
 	u32 offset = 0, dwords_read, size_param_offset;
 	bool fifo_has_data;
@@ -4255,10 +4255,11 @@ enum dbg_status qed_igu_fifo_dump(struct qed_hwfn *p_hwfn,
 }
 
 /* Protection Override dump */
-enum dbg_status qed_protection_override_dump(struct qed_hwfn *p_hwfn,
-					     struct qed_ptt *p_ptt,
-					     u32 *dump_buf,
-					     bool dump, u32 *num_dumped_dwords)
+static enum
+dbg_status qed_protection_override_dump(struct qed_hwfn *p_hwfn,
+					struct qed_ptt *p_ptt,
+					u32 *dump_buf,
+					bool dump, u32 *num_dumped_dwords)
 {
 	u32 offset = 0, size_param_offset, override_window_dwords;
 
@@ -6339,10 +6340,11 @@ enum dbg_status qed_print_fw_asserts_results(struct qed_hwfn *p_hwfn,
 }
 
 /* Wrapper for unifying the idle_chk and mcp_trace api */
-enum dbg_status qed_print_idle_chk_results_wrapper(struct qed_hwfn *p_hwfn,
-						   u32 *dump_buf,
-						   u32 num_dumped_dwords,
-						   char *results_buf)
+static enum
+dbg_status qed_print_idle_chk_results_wrapper(struct qed_hwfn *p_hwfn,
+					      u32 *dump_buf,
+					      u32 num_dumped_dwords,
+					      char *results_buf)
 {
 	u32 num_errors, num_warnnings;
 
@@ -6413,8 +6415,8 @@ static void qed_dbg_print_feature(u8 *p_text_buf, u32 text_size)
 
 #define QED_RESULTS_BUF_MIN_SIZE 16
 /* Generic function for decoding debug feature info */
-enum dbg_status format_feature(struct qed_hwfn *p_hwfn,
-			       enum qed_dbg_features feature_idx)
+static enum dbg_status format_feature(struct qed_hwfn *p_hwfn,
+				      enum qed_dbg_features feature_idx)
 {
 	struct qed_dbg_feature *feature =
 	    &p_hwfn->cdev->dbg_params.features[feature_idx];
@@ -6480,8 +6482,9 @@ enum dbg_status format_feature(struct qed_hwfn *p_hwfn,
 }
 
 /* Generic function for performing the dump of a debug feature. */
-enum dbg_status qed_dbg_dump(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			     enum qed_dbg_features feature_idx)
+static enum
+dbg_status qed_dbg_dump(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
+			enum qed_dbg_features feature_idx)
 {
 	struct qed_dbg_feature *feature =
 	    &p_hwfn->cdev->dbg_params.features[feature_idx];
-- 
2.7.4
