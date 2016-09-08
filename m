From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH v2] qed: mark symbols static where possible
Date: Thu,  8 Sep 2016 16:25:17 +0800
Message-ID: <1473323117-8772-1-git-send-email-baoyou.xie@linaro.org>
Cc: everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org,
        xie.baoyou@zte.com.cn
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a few warnings when building kernel with W=1:
drivers/net/ethernet/qlogic/qed/qed_l2.c:112:5: warning: no previous prototype for 'qed_sp_vport_start' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:110:6: warning: no previous prototype for 'qed_iov_is_valid_vfid' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:188:5: warning: no previous prototype for 'qed_iov_post_vf_bulletin' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:578:6: warning: no previous prototype for 'qed_iov_set_vfs_to_disable' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:1135:28: warning: no previous prototype for 'qed_iov_get_public_vf_info' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:1148:6: warning: no previous prototype for 'qed_iov_clean_vf' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:2444:5: warning: no previous prototype for 'qed_iov_chk_ucast' [-Wmissing-prototypes]
drivers/net/ethernet/qlogic/qed/qed_sriov.c:2762:5: warning: no previous prototype for 'qed_iov_vf_flr_cleanup' [-Wmissing-prototypes]
....

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c  | 9 ++++---
 drivers/net/ethernet/qlogic/qed/qed_l2.c    | 10 +++----
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 45 ++++++++++++++++-------------
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  4 +--
 4 files changed, 37 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index d0dc28f..688001e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -2023,17 +2023,19 @@ static int qed_dcbnl_ieee_setets(struct qed_dev *cdev, struct ieee_ets *ets)
 	return rc;
 }
 
-int qed_dcbnl_ieee_peer_getets(struct qed_dev *cdev, struct ieee_ets *ets)
+static int
+qed_dcbnl_ieee_peer_getets(struct qed_dev *cdev, struct ieee_ets *ets)
 {
 	return qed_dcbnl_get_ieee_ets(cdev, ets, true);
 }
 
-int qed_dcbnl_ieee_peer_getpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
+static int
+qed_dcbnl_ieee_peer_getpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
 {
 	return qed_dcbnl_get_ieee_pfc(cdev, pfc, true);
 }
 
-int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
+static int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_dcbx_get *dcbx_info;
@@ -2077,7 +2079,7 @@ int qed_dcbnl_ieee_getapp(struct qed_dev *cdev, struct dcb_app *app)
 	return 0;
 }
 
-int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
+static int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
 	struct qed_dcbx_get *dcbx_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 401e738..35b4cfb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -109,8 +109,8 @@ int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
-int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
-		       struct qed_sp_vport_start_params *p_params)
+static int qed_sp_vport_start(struct qed_hwfn *p_hwfn,
+			      struct qed_sp_vport_start_params *p_params)
 {
 	if (IS_VF(p_hwfn->cdev)) {
 		return qed_vf_pf_vport_start(p_hwfn, p_params->vport_id,
@@ -1541,7 +1541,7 @@ static void __qed_get_vport_port_stats(struct qed_hwfn *p_hwfn,
 	}
 }
 
-void qed_get_vport_stats(struct qed_dev *cdev,
-			 struct qed_eth_stats *stats)
+static void qed_get_vport_stats(struct qed_dev *cdev,
+				struct qed_eth_stats *stats)
 {
 	u32 i;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 15399da..8fb500e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -107,8 +107,8 @@ static int qed_sp_vf_stop(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
-bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
-			   int rel_vf_id, bool b_enabled_only)
+static bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
+				  int rel_vf_id, bool b_enabled_only)
 {
 	if (!p_hwfn->pf_iov_info) {
 		DP_NOTICE(p_hwfn->cdev, "No iov info\n");
@@ -185,8 +185,8 @@ static bool qed_iov_validate_sb(struct qed_hwfn *p_hwfn,
 	return false;
 }
 
-int qed_iov_post_vf_bulletin(struct qed_hwfn *p_hwfn,
-			     int vfid, struct qed_ptt *p_ptt)
+static int qed_iov_post_vf_bulletin(struct qed_hwfn *p_hwfn,
+				    int vfid, struct qed_ptt *p_ptt)
 {
 	struct qed_bulletin_content *p_bulletin;
 	int crc_size = sizeof(p_bulletin->crc);
@@ -575,7 +575,7 @@ static void qed_iov_set_vf_to_disable(struct qed_dev *cdev,
 	}
 }
 
-void qed_iov_set_vfs_to_disable(struct qed_dev *cdev, u8 to_disable)
+static void qed_iov_set_vfs_to_disable(struct qed_dev *cdev, u8 to_disable)
 {
 	u16 i;
 
@@ -1132,9 +1132,10 @@ static void qed_iov_prepare_resp(struct qed_hwfn *p_hwfn,
 	qed_iov_send_response(p_hwfn, p_ptt, vf_info, length, status);
 }
 
-struct qed_public_vf_info *qed_iov_get_public_vf_info(struct qed_hwfn *p_hwfn,
-						      u16 relative_vf_id,
-						      bool b_enabled_only)
+static struct
+qed_public_vf_info *qed_iov_get_public_vf_info(struct qed_hwfn *p_hwfn,
+					       u16 relative_vf_id,
+					       bool b_enabled_only)
 {
 	struct qed_vf_info *vf = NULL;
 
@@ -1145,7 +1146,7 @@ struct qed_public_vf_info *qed_iov_get_public_vf_info(struct qed_hwfn *p_hwfn,
 	return &vf->p_vf_info;
 }
 
-void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
+static void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
 {
 	struct qed_public_vf_info *vf_info;
 
@@ -2441,8 +2442,8 @@ qed_iov_vf_update_unicast_shadow(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-int qed_iov_chk_ucast(struct qed_hwfn *hwfn,
-		      int vfid, struct qed_filter_ucast *params)
+static int qed_iov_chk_ucast(struct qed_hwfn *hwfn,
+			     int vfid, struct qed_filter_ucast *params)
 {
 	struct qed_public_vf_info *vf;
 
@@ -2759,7 +2760,8 @@ cleanup:
 	return rc;
 }
 
-int qed_iov_vf_flr_cleanup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+static int
+qed_iov_vf_flr_cleanup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	u32 ack_vfs[VF_MAX_STATIC / 32];
 	int rc = 0;
@@ -2946,7 +2948,7 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 	}
 }
 
-void qed_iov_pf_add_pending_events(struct qed_hwfn *p_hwfn, u8 vfid)
+static void qed_iov_pf_add_pending_events(struct qed_hwfn *p_hwfn, u8 vfid)
 {
 	u64 add_bit = 1ULL << (vfid % 64);
 
@@ -3070,8 +3072,8 @@ static void qed_iov_bulletin_set_forced_mac(struct qed_hwfn *p_hwfn,
 	qed_iov_configure_vport_forced(p_hwfn, vf_info, feature);
 }
 
-void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
-				      u16 pvid, int vfid)
+static void qed_iov_bulletin_set_forced_vlan(struct qed_hwfn *p_hwfn,
+					     u16 pvid, int vfid)
 {
 	struct qed_vf_info *vf_info;
 	u64 feature;
@@ -3104,7 +3106,7 @@ static bool qed_iov_vf_has_vport_instance(struct qed_hwfn *p_hwfn, int vfid)
 	return !!p_vf_info->vport_instance;
 }
 
-bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
+static bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
 {
 	struct qed_vf_info *p_vf_info;
 
@@ -3126,7 +3128,7 @@ static bool qed_iov_spoofchk_get(struct qed_hwfn *p_hwfn, int vfid)
 	return vf_info->spoof_chk;
 }
 
-int qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn, int vfid, bool val)
+static int qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn, int vfid, bool val)
 {
 	struct qed_vf_info *vf;
 	int rc = -EINVAL;
@@ -3169,7 +3171,8 @@ static u8 *qed_iov_bulletin_get_forced_mac(struct qed_hwfn *p_hwfn,
 	return p_vf->bulletin.p_virt->mac;
 }
 
-u16 qed_iov_bulletin_get_forced_vlan(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
+static u16
+qed_iov_bulletin_get_forced_vlan(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
 {
 	struct qed_vf_info *p_vf;
 
@@ -3201,7 +3204,8 @@ static int qed_iov_configure_tx_rate(struct qed_hwfn *p_hwfn,
 	return qed_init_vport_rl(p_hwfn, p_ptt, abs_vp_id, (u32)val);
 }
 
-int qed_iov_configure_min_tx_rate(struct qed_dev *cdev, int vfid, u32 rate)
+static int
+qed_iov_configure_min_tx_rate(struct qed_dev *cdev, int vfid, u32 rate)
 {
 	struct qed_vf_info *vf;
 	u8 vport_id;
@@ -3760,7 +3764,8 @@ static void qed_handle_bulletin_post(struct qed_hwfn *hwfn)
 	qed_ptt_release(hwfn, ptt);
 }
 
-void qed_iov_pf_task(struct work_struct *work)
+static void qed_iov_pf_task(struct work_struct *work)
+
 {
 	struct qed_hwfn *hwfn = container_of(work, struct qed_hwfn,
 					     iov_task.work);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 9b780b3..cc69ec4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1071,8 +1071,8 @@ bool qed_vf_check_mac(struct qed_hwfn *p_hwfn, u8 *mac)
 	return false;
 }
 
-bool qed_vf_bulletin_get_forced_mac(struct qed_hwfn *hwfn,
-				    u8 *dst_mac, u8 *p_is_forced)
+static bool qed_vf_bulletin_get_forced_mac(struct qed_hwfn *hwfn,
+					   u8 *dst_mac, u8 *p_is_forced)
 {
 	struct qed_bulletin_content *bulletin;
 
-- 
2.7.4
