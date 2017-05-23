From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 05/11] qed: Drop the 's' from num_ports_in_engines
Date: Tue, 23 May 2017 09:41:22 +0300
Message-ID: <1495521688-27669-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0063.outbound.protection.outlook.com ([104.47.33.63]:21922
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965820AbdEWGmi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:38 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

The parameter reflects the number of physical ports connected to a single
engine, not all.

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 36 +++++++++++++++----------------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_ptp.c |  4 ++--
 4 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index fd8cf31..63c44c6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -633,7 +633,7 @@ struct qed_dev {
 #define CHIP_BOND_ID_SHIFT              0
 
 	u8				num_engines;
-	u8				num_ports_in_engines;
+	u8				num_ports_in_engine;
 	u8				num_funcs_in_port;
 
 	u8				path_id;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b01df24..51ae907 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -300,7 +300,7 @@ static void qed_init_qm_params(struct qed_hwfn *p_hwfn)
 	qm_info->vport_wfq_en = 1;
 
 	/* TC config is different for AH 4 port */
-	four_port = p_hwfn->cdev->num_ports_in_engines == MAX_NUM_PORTS_K2;
+	four_port = p_hwfn->cdev->num_ports_in_engine == MAX_NUM_PORTS_K2;
 
 	/* in AH 4 port we have fewer TCs per port */
 	qm_info->max_phys_tcs_per_port = four_port ? NUM_PHYS_TCS_4PORT_K2 :
@@ -329,7 +329,7 @@ static void qed_init_qm_vport_params(struct qed_hwfn *p_hwfn)
 static void qed_init_qm_port_params(struct qed_hwfn *p_hwfn)
 {
 	/* Initialize qm port parameters */
-	u8 i, active_phys_tcs, num_ports = p_hwfn->cdev->num_ports_in_engines;
+	u8 i, active_phys_tcs, num_ports = p_hwfn->cdev->num_ports_in_engine;
 
 	/* indicate how ooo and high pri traffic is dealt with */
 	active_phys_tcs = num_ports == MAX_NUM_PORTS_K2 ?
@@ -693,7 +693,7 @@ static void qed_dp_init_qm_params(struct qed_hwfn *p_hwfn)
 		   qm_info->num_pf_rls, qed_get_pq_flags(p_hwfn));
 
 	/* port table */
-	for (i = 0; i < p_hwfn->cdev->num_ports_in_engines; i++) {
+	for (i = 0; i < p_hwfn->cdev->num_ports_in_engine; i++) {
 		port = &(qm_info->qm_port_params[i]);
 		DP_VERBOSE(p_hwfn,
 			   NETIF_MSG_HW,
@@ -823,7 +823,7 @@ static int qed_alloc_qm_data(struct qed_hwfn *p_hwfn)
 		goto alloc_err;
 
 	qm_info->qm_port_params = kzalloc(sizeof(*qm_info->qm_port_params) *
-					  p_hwfn->cdev->num_ports_in_engines,
+					  p_hwfn->cdev->num_ports_in_engine,
 					  GFP_KERNEL);
 	if (!qm_info->qm_port_params)
 		goto alloc_err;
@@ -1108,7 +1108,7 @@ static int qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
 		return -EINVAL;
 	}
 
-	switch (p_hwfn->cdev->num_ports_in_engines) {
+	switch (p_hwfn->cdev->num_ports_in_engine) {
 	case 1:
 		hw_mode |= 1 << MODE_PORTS_PER_ENG_1;
 		break;
@@ -1120,7 +1120,7 @@ static int qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
 		break;
 	default:
 		DP_NOTICE(p_hwfn, "num_ports_in_engine = %d not supported\n",
-			  p_hwfn->cdev->num_ports_in_engines);
+			  p_hwfn->cdev->num_ports_in_engine);
 		return -EINVAL;
 	}
 
@@ -1253,7 +1253,7 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	}
 
 	memset(&params, 0, sizeof(params));
-	params.max_ports_per_engine = p_hwfn->cdev->num_ports_in_engines;
+	params.max_ports_per_engine = p_hwfn->cdev->num_ports_in_engine;
 	params.max_phys_tcs_per_port = qm_info->max_phys_tcs_per_port;
 	params.pf_rl_en = qm_info->pf_rl_en;
 	params.pf_wfq_en = qm_info->pf_wfq_en;
@@ -2245,7 +2245,7 @@ int qed_hw_get_dflt_resc(struct qed_hwfn *p_hwfn,
 	case QED_BDQ:
 		if (!*p_resc_num)
 			*p_resc_start = 0;
-		else if (p_hwfn->cdev->num_ports_in_engines == 4)
+		else if (p_hwfn->cdev->num_ports_in_engine == 4)
 			*p_resc_start = p_hwfn->port_id;
 		else if (p_hwfn->hw_info.personality == QED_PCI_ISCSI)
 			*p_resc_start = p_hwfn->port_id;
@@ -2662,15 +2662,15 @@ static void qed_hw_info_port_num_bb(struct qed_hwfn *p_hwfn,
 	port_mode = qed_rd(p_hwfn, p_ptt, CNIG_REG_NW_PORT_MODE_BB_B0);
 
 	if (port_mode < 3) {
-		p_hwfn->cdev->num_ports_in_engines = 1;
+		p_hwfn->cdev->num_ports_in_engine = 1;
 	} else if (port_mode <= 5) {
-		p_hwfn->cdev->num_ports_in_engines = 2;
+		p_hwfn->cdev->num_ports_in_engine = 2;
 	} else {
 		DP_NOTICE(p_hwfn, "PORT MODE: %d not supported\n",
-			  p_hwfn->cdev->num_ports_in_engines);
+			  p_hwfn->cdev->num_ports_in_engine);
 
-		/* Default num_ports_in_engines to something */
-		p_hwfn->cdev->num_ports_in_engines = 1;
+		/* Default num_ports_in_engine to something */
+		p_hwfn->cdev->num_ports_in_engine = 1;
 	}
 }
 
@@ -2680,20 +2680,20 @@ static void qed_hw_info_port_num_ah(struct qed_hwfn *p_hwfn,
 	u32 port;
 	int i;
 
-	p_hwfn->cdev->num_ports_in_engines = 0;
+	p_hwfn->cdev->num_ports_in_engine = 0;
 
 	for (i = 0; i < MAX_NUM_PORTS_K2; i++) {
 		port = qed_rd(p_hwfn, p_ptt,
 			      CNIG_REG_NIG_PORT0_CONF_K2 + (i * 4));
 		if (port & 1)
-			p_hwfn->cdev->num_ports_in_engines++;
+			p_hwfn->cdev->num_ports_in_engine++;
 	}
 
-	if (!p_hwfn->cdev->num_ports_in_engines) {
+	if (!p_hwfn->cdev->num_ports_in_engine) {
 		DP_NOTICE(p_hwfn, "All NIG ports are inactive\n");
 
 		/* Default num_ports_in_engine to something */
-		p_hwfn->cdev->num_ports_in_engines = 1;
+		p_hwfn->cdev->num_ports_in_engine = 1;
 	}
 }
 
@@ -4067,7 +4067,7 @@ static int qed_device_num_ports(struct qed_dev *cdev)
 	if (cdev->num_hwfns > 1)
 		return 1;
 
-	return cdev->num_ports_in_engines * qed_device_num_engines(cdev);
+	return cdev->num_ports_in_engine * qed_device_num_engines(cdev);
 }
 
 int qed_device_get_port_id(struct qed_dev *cdev)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 2b09b85..3e5bffe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -482,7 +482,7 @@ int qed_mcp_bist_nvm_test_get_image_att(struct qed_hwfn *p_hwfn,
 #define MCP_PF_ID(p_hwfn) MCP_PF_ID_BY_REL(p_hwfn, (p_hwfn)->rel_pf_id)
 
 #define MFW_PORT(_p_hwfn)       ((_p_hwfn)->abs_pf_id %			  \
-				 ((_p_hwfn)->cdev->num_ports_in_engines * \
+				 ((_p_hwfn)->cdev->num_ports_in_engine * \
 				  qed_device_num_engines((_p_hwfn)->cdev)))
 
 struct qed_mcp_info {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.c b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
index 434a164..5a90d69 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
@@ -80,7 +80,7 @@ static int qed_ptp_res_lock(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		/* MFW doesn't support resource locking, first PF on the port
 		 * has lock ownership.
 		 */
-		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engines)
+		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engine)
 			return 0;
 
 		DP_INFO(p_hwfn, "PF doesn't have lock ownership\n");
@@ -108,7 +108,7 @@ static int qed_ptp_res_unlock(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	rc = qed_mcp_resc_unlock(p_hwfn, p_ptt, &params);
 	if (rc == -EINVAL) {
 		/* MFW doesn't support locking, first PF has lock ownership */
-		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engines) {
+		if (p_hwfn->abs_pf_id < p_hwfn->cdev->num_ports_in_engine) {
 			rc = 0;
 		} else {
 			DP_INFO(p_hwfn, "PF doesn't have lock ownership\n");
-- 
1.9.3
