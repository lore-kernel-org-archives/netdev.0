From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum: Fix sparse warnings
Date: Mon, 19 Sep 2016 08:29:26 +0200
Message-ID: <1474266566-5780-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34065 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754425AbcISG3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 02:29:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id l132so11969332wmf.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 23:29:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

drivers/net/ethernet/mellanox/mlxsw//spectrum.c:251:28: warning: symbol
'mlxsw_sp_span_entry_find' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlxsw//spectrum.c:265:28: warning: symbol
'mlxsw_sp_span_entry_get' was not declared. Should it be static?
drivers/net/ethernet/mellanox/mlxsw//spectrum.c:367:56: warning: mixing
different enum types
drivers/net/ethernet/mellanox/mlxsw//spectrum.c:367:56:     int enum
mlxsw_sp_span_type  versus
drivers/net/ethernet/mellanox/mlxsw//spectrum.c:367:56:     int enum
mlxsw_reg_mpar_i_e
...
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:598:32: warning:
mixing different enum types
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:598:32:     int
enum mlxsw_reg_sbxx_dir  versus
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:598:32:     int
enum devlink_sb_pool_type
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:600:39: warning:
mixing different enum types
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:600:39:     int
enum mlxsw_reg_sbpr_mode  versus
drivers/net/ethernet/mellanox/mlxsw//spectrum_buffers.c:600:39:     int
enum devlink_sb_threshold_type
...
drivers/net/ethernet/mellanox/mlxsw//spectrum_router.c:255:54: warning:
mixing different enum types
drivers/net/ethernet/mellanox/mlxsw//spectrum_router.c:255:54:     int
enum mlxsw_sp_l3proto  versus
drivers/net/ethernet/mellanox/mlxsw//spectrum_router.c:255:54:     int
enum mlxsw_reg_ralxx_protocol
...
drivers/net/ethernet/mellanox/mlxsw//spectrum_router.c:1749:6: warning:
symbol 'mlxsw_sp_fib_entry_put' was not declared. Should it be static?

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 12 ++++---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 15 ++++----
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 41 ++++++++++++++--------
 3 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 171f8dd..fa31261 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -248,7 +248,8 @@ static void mlxsw_sp_span_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 	span_entry->used = false;
 }
 
-struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
+static struct mlxsw_sp_span_entry *
+mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
 {
 	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
 	int i;
@@ -262,7 +263,8 @@ struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
 	return NULL;
 }
 
-struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_get(struct mlxsw_sp_port *port)
+static struct mlxsw_sp_span_entry
+*mlxsw_sp_span_entry_get(struct mlxsw_sp_port *port)
 {
 	struct mlxsw_sp_span_entry *span_entry;
 
@@ -364,7 +366,8 @@ mlxsw_sp_span_inspected_port_bind(struct mlxsw_sp_port *port,
 	}
 
 	/* bind the port to the SPAN entry */
-	mlxsw_reg_mpar_pack(mpar_pl, port->local_port, type, true, pa_id);
+	mlxsw_reg_mpar_pack(mpar_pl, port->local_port,
+			    (enum mlxsw_reg_mpar_i_e) type, true, pa_id);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpar), mpar_pl);
 	if (err)
 		goto err_mpar_reg_write;
@@ -405,7 +408,8 @@ mlxsw_sp_span_inspected_port_unbind(struct mlxsw_sp_port *port,
 		return;
 
 	/* remove the inspected port */
-	mlxsw_reg_mpar_pack(mpar_pl, port->local_port, type, false, pa_id);
+	mlxsw_reg_mpar_pack(mpar_pl, port->local_port,
+			    (enum mlxsw_reg_mpar_i_e) type, false, pa_id);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpar), mpar_pl);
 
 	/* remove the SBIB buffer if it was egress SPAN */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 953b214..bcaed8a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -595,9 +595,9 @@ int mlxsw_sp_sb_pool_get(struct mlxsw_core *mlxsw_core,
 	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
 	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
 
-	pool_info->pool_type = dir;
+	pool_info->pool_type = (enum devlink_sb_pool_type) dir;
 	pool_info->size = MLXSW_SP_CELLS_TO_BYTES(pr->size);
-	pool_info->threshold_type = pr->mode;
+	pool_info->threshold_type = (enum devlink_sb_threshold_type) pr->mode;
 	return 0;
 }
 
@@ -608,9 +608,10 @@ int mlxsw_sp_sb_pool_set(struct mlxsw_core *mlxsw_core,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 	u8 pool = pool_get(pool_index);
 	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
-	enum mlxsw_reg_sbpr_mode mode = threshold_type;
 	u32 pool_size = MLXSW_SP_BYTES_TO_CELLS(size);
+	enum mlxsw_reg_sbpr_mode mode;
 
+	mode = (enum mlxsw_reg_sbpr_mode) threshold_type;
 	return mlxsw_sp_sb_pr_write(mlxsw_sp, pool, dir, mode, pool_size);
 }
 
@@ -696,13 +697,13 @@ int mlxsw_sp_sb_tc_pool_bind_get(struct mlxsw_core_port *mlxsw_core_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u8 local_port = mlxsw_sp_port->local_port;
 	u8 pg_buff = tc_index;
-	enum mlxsw_reg_sbxx_dir dir = pool_type;
+	enum mlxsw_reg_sbxx_dir dir = (enum mlxsw_reg_sbxx_dir) pool_type;
 	struct mlxsw_sp_sb_cm *cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port,
 						       pg_buff, dir);
 
 	*p_threshold = mlxsw_sp_sb_threshold_out(mlxsw_sp, cm->pool, dir,
 						 cm->max_buff);
-	*p_pool_index = pool_index_get(cm->pool, pool_type);
+	*p_pool_index = pool_index_get(cm->pool, dir);
 	return 0;
 }
 
@@ -716,7 +717,7 @@ int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u8 local_port = mlxsw_sp_port->local_port;
 	u8 pg_buff = tc_index;
-	enum mlxsw_reg_sbxx_dir dir = pool_type;
+	enum mlxsw_reg_sbxx_dir dir = (enum mlxsw_reg_sbxx_dir) pool_type;
 	u8 pool = pool_get(pool_index);
 	u32 max_buff;
 	int err;
@@ -943,7 +944,7 @@ int mlxsw_sp_sb_occ_tc_port_bind_get(struct mlxsw_core_port *mlxsw_core_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u8 local_port = mlxsw_sp_port->local_port;
 	u8 pg_buff = tc_index;
-	enum mlxsw_reg_sbxx_dir dir = pool_type;
+	enum mlxsw_reg_sbxx_dir dir = (enum mlxsw_reg_sbxx_dir) pool_type;
 	struct mlxsw_sp_sb_cm *cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port,
 						       pg_buff, dir);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3f5c51d..4afb498 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -252,7 +252,9 @@ static int mlxsw_sp_lpm_tree_alloc(struct mlxsw_sp *mlxsw_sp,
 {
 	char ralta_pl[MLXSW_REG_RALTA_LEN];
 
-	mlxsw_reg_ralta_pack(ralta_pl, true, lpm_tree->proto, lpm_tree->id);
+	mlxsw_reg_ralta_pack(ralta_pl, true,
+			     (enum mlxsw_reg_ralxx_protocol) lpm_tree->proto,
+			     lpm_tree->id);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
 }
 
@@ -261,7 +263,9 @@ static int mlxsw_sp_lpm_tree_free(struct mlxsw_sp *mlxsw_sp,
 {
 	char ralta_pl[MLXSW_REG_RALTA_LEN];
 
-	mlxsw_reg_ralta_pack(ralta_pl, false, lpm_tree->proto, lpm_tree->id);
+	mlxsw_reg_ralta_pack(ralta_pl, false,
+			     (enum mlxsw_reg_ralxx_protocol) lpm_tree->proto,
+			     lpm_tree->id);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
 }
 
@@ -384,7 +388,9 @@ static int mlxsw_sp_vr_lpm_tree_bind(struct mlxsw_sp *mlxsw_sp,
 {
 	char raltb_pl[MLXSW_REG_RALTB_LEN];
 
-	mlxsw_reg_raltb_pack(raltb_pl, vr->id, vr->proto, vr->lpm_tree->id);
+	mlxsw_reg_raltb_pack(raltb_pl, vr->id,
+			     (enum mlxsw_reg_ralxx_protocol) vr->proto,
+			     vr->lpm_tree->id);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 }
 
@@ -394,7 +400,8 @@ static int mlxsw_sp_vr_lpm_tree_unbind(struct mlxsw_sp *mlxsw_sp,
 	char raltb_pl[MLXSW_REG_RALTB_LEN];
 
 	/* Bind to tree 0 which is default */
-	mlxsw_reg_raltb_pack(raltb_pl, vr->id, vr->proto, 0);
+	mlxsw_reg_raltb_pack(raltb_pl, vr->id,
+			     (enum mlxsw_reg_ralxx_protocol) vr->proto, 0);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 }
 
@@ -1081,9 +1088,10 @@ static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
 {
 	char raleu_pl[MLXSW_REG_RALEU_LEN];
 
-	mlxsw_reg_raleu_pack(raleu_pl, vr->proto, vr->id,
-			     adj_index, ecmp_size,
-			     new_adj_index, new_ecmp_size);
+	mlxsw_reg_raleu_pack(raleu_pl,
+			     (enum mlxsw_reg_ralxx_protocol) vr->proto, vr->id,
+			     adj_index, ecmp_size, new_adj_index,
+			     new_ecmp_size);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raleu), raleu_pl);
 }
 
@@ -1558,8 +1566,9 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
 	}
 
-	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
-			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_pack4(ralue_pl,
+			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
+			      vr->id, fib_entry->key.prefix_len, *p_dip);
 	mlxsw_reg_ralue_act_remote_pack(ralue_pl, trap_action, trap_id,
 					adjacency_index, ecmp_size);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
@@ -1573,8 +1582,9 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 	u32 *p_dip = (u32 *) fib_entry->key.addr;
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
-	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
-			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_pack4(ralue_pl,
+			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
+			      vr->id, fib_entry->key.prefix_len, *p_dip);
 	mlxsw_reg_ralue_act_local_pack(ralue_pl,
 				       MLXSW_REG_RALUE_TRAP_ACTION_NOP, 0,
 				       fib_entry->rif);
@@ -1589,8 +1599,9 @@ static int mlxsw_sp_fib_entry_op4_trap(struct mlxsw_sp *mlxsw_sp,
 	u32 *p_dip = (u32 *) fib_entry->key.addr;
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
-	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
-			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_pack4(ralue_pl,
+			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
+			      vr->id, fib_entry->key.prefix_len, *p_dip);
 	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
@@ -1753,8 +1764,8 @@ mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
 					 fib4->fi->fib_dev);
 }
 
-void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
-			    struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
 
-- 
2.5.5
