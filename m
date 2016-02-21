From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/5] qed: Turn most GFP_ATOMIC into GFP_KERNEL
Date: Sun, 21 Feb 2016 11:40:07 +0200
Message-ID: <1456047611-11222-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46415 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751302AbcBURpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:30 -0500
In-Reply-To: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial driver submission used GFP_ATOMIC almost inclusively when
allocating memory. We now remedy this point, using GFP_KERNEL where
it's possible.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 6 +++---
 drivers/net/ethernet/qlogic/qed/qed_hw.c  | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_int.c | 8 ++++----
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 6 +++---
 drivers/net/ethernet/qlogic/qed/qed_spq.c | 6 +++---
 6 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index d3f7a02..fc767c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -448,7 +448,7 @@ int qed_cxt_mngr_alloc(struct qed_hwfn *p_hwfn)
 	struct qed_cxt_mngr *p_mngr;
 	u32 i;
 
-	p_mngr = kzalloc(sizeof(*p_mngr), GFP_ATOMIC);
+	p_mngr = kzalloc(sizeof(*p_mngr), GFP_KERNEL);
 	if (!p_mngr) {
 		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_cxt_mngr'\n");
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index bc17ed2..acfe7be 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -134,17 +134,17 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
 	/* PQs will be arranged as follows: First per-TC PQ then pure-LB quete.
 	 */
 	qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
-					num_pqs, GFP_ATOMIC);
+					num_pqs, GFP_KERNEL);
 	if (!qm_info->qm_pq_params)
 		goto alloc_err;
 
 	qm_info->qm_vport_params = kzalloc(sizeof(*qm_info->qm_vport_params) *
-					   num_vports, GFP_ATOMIC);
+					   num_vports, GFP_KERNEL);
 	if (!qm_info->qm_vport_params)
 		goto alloc_err;
 
 	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
-					  MAX_NUM_PORTS, GFP_ATOMIC);
+					  MAX_NUM_PORTS, GFP_KERNEL);
 	if (!qm_info->qm_port_params)
 		goto alloc_err;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index ffa9927..a95a3e4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -44,7 +44,7 @@ struct qed_ptt_pool {
 int qed_ptt_pool_alloc(struct qed_hwfn *p_hwfn)
 {
 	struct qed_ptt_pool *p_pool = kmalloc(sizeof(*p_pool),
-					      GFP_ATOMIC);
+					      GFP_KERNEL);
 	int i;
 
 	if (!p_pool)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 9cc9d62..90ba1d7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -399,7 +399,7 @@ static int qed_int_sb_attn_alloc(struct qed_hwfn *p_hwfn,
 	dma_addr_t p_phys = 0;
 
 	/* SB struct */
-	p_sb = kmalloc(sizeof(*p_sb), GFP_ATOMIC);
+	p_sb = kmalloc(sizeof(*p_sb), GFP_KERNEL);
 	if (!p_sb) {
 		DP_NOTICE(cdev, "Failed to allocate `struct qed_sb_attn_info'\n");
 		return -ENOMEM;
@@ -666,7 +666,7 @@ static int qed_int_sp_sb_alloc(struct qed_hwfn *p_hwfn,
 	void *p_virt;
 
 	/* SB struct */
-	p_sb = kmalloc(sizeof(*p_sb), GFP_ATOMIC);
+	p_sb = kmalloc(sizeof(*p_sb), GFP_KERNEL);
 	if (!p_sb) {
 		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_sb_info'\n");
 		return -ENOMEM;
@@ -946,7 +946,7 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn,
 	u16 sb_id;
 	u16 prev_sb_id = 0xFF;
 
-	p_hwfn->hw_info.p_igu_info = kzalloc(sizeof(*p_igu_info), GFP_ATOMIC);
+	p_hwfn->hw_info.p_igu_info = kzalloc(sizeof(*p_igu_info), GFP_KERNEL);
 
 	if (!p_hwfn->hw_info.p_igu_info)
 		return -ENOMEM;
@@ -1072,7 +1072,7 @@ static void qed_int_sp_dpc_setup(struct qed_hwfn *p_hwfn)
 
 static int qed_int_sp_dpc_alloc(struct qed_hwfn *p_hwfn)
 {
-	p_hwfn->sp_dpc = kmalloc(sizeof(*p_hwfn->sp_dpc), GFP_ATOMIC);
+	p_hwfn->sp_dpc = kmalloc(sizeof(*p_hwfn->sp_dpc), GFP_KERNEL);
 	if (!p_hwfn->sp_dpc)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 1457e30..f23ce73 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -147,7 +147,7 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn,
 	u32 size;
 
 	/* Allocate mcp_info structure */
-	p_hwfn->mcp_info = kzalloc(sizeof(*p_hwfn->mcp_info), GFP_ATOMIC);
+	p_hwfn->mcp_info = kzalloc(sizeof(*p_hwfn->mcp_info), GFP_KERNEL);
 	if (!p_hwfn->mcp_info)
 		goto err;
 	p_info = p_hwfn->mcp_info;
@@ -161,10 +161,10 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn,
 	}
 
 	size = MFW_DRV_MSG_MAX_DWORDS(p_info->mfw_mb_length) * sizeof(u32);
-	p_info->mfw_mb_cur = kzalloc(size, GFP_ATOMIC);
+	p_info->mfw_mb_cur = kzalloc(size, GFP_KERNEL);
 	p_info->mfw_mb_shadow =
 		kzalloc(sizeof(u32) * MFW_DRV_MSG_MAX_DWORDS(
-				p_info->mfw_mb_length), GFP_ATOMIC);
+				p_info->mfw_mb_length), GFP_KERNEL);
 	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
 		goto err;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 3dd548a..f6c6c21 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -327,7 +327,7 @@ struct qed_eq *qed_eq_alloc(struct qed_hwfn *p_hwfn,
 	struct qed_eq *p_eq;
 
 	/* Allocate EQ struct */
-	p_eq = kzalloc(sizeof(*p_eq), GFP_ATOMIC);
+	p_eq = kzalloc(sizeof(*p_eq), GFP_KERNEL);
 	if (!p_eq) {
 		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_eq'\n");
 		return NULL;
@@ -457,7 +457,7 @@ int qed_spq_alloc(struct qed_hwfn *p_hwfn)
 
 	/* SPQ struct */
 	p_spq =
-		kzalloc(sizeof(struct qed_spq), GFP_ATOMIC);
+		kzalloc(sizeof(struct qed_spq), GFP_KERNEL);
 	if (!p_spq) {
 		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_spq'\n");
 		return -ENOMEM;
@@ -853,7 +853,7 @@ struct qed_consq *qed_consq_alloc(struct qed_hwfn *p_hwfn)
 	struct qed_consq *p_consq;
 
 	/* Allocate ConsQ struct */
-	p_consq = kzalloc(sizeof(*p_consq), GFP_ATOMIC);
+	p_consq = kzalloc(sizeof(*p_consq), GFP_KERNEL);
 	if (!p_consq) {
 		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_consq'\n");
 		return NULL;
-- 
1.9.3
