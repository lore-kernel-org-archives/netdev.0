From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 1/6] {net, IB}/mlx5: Replace mlx5_vzalloc with kvzalloc
Date: Tue, 23 May 2017 14:43:59 +0300
Message-ID: <20170523114404.20387-2-saeedm@mellanox.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170523114404.20387-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Commit a7c3e901a46f ("mm: introduce kv[mz]alloc helpers") added
proper implementation of mlx5_vzalloc function to the MM core.

This made the mlx5_vzalloc function useless, so let's remove it.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/cq.c                    |  6 ++--
 drivers/infiniband/hw/mlx5/mad.c                   |  4 +--
 drivers/infiniband/hw/mlx5/main.c                  |  6 ++--
 drivers/infiniband/hw/mlx5/mr.c                    |  2 +-
 drivers/infiniband/hw/mlx5/qp.c                    | 32 ++++++++++----------
 drivers/infiniband/hw/mlx5/srq.c                   |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  8 ++---
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  4 +--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 24 ++++++---------
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 33 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 24 ++++++---------
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 13 ++++-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 10 +++----
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    |  2 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      | 14 ++++-----
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    | 34 +++++++++-------------
 include/linux/mlx5/driver.h                        |  5 ----
 27 files changed, 111 insertions(+), 144 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 94c049b62c2f..a384d72ea3cd 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -788,7 +788,7 @@ static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
 
 	*inlen = MLX5_ST_SZ_BYTES(create_cq_in) +
 		 MLX5_FLD_SZ_BYTES(create_cq_in, pas[0]) * ncont;
-	*cqb = mlx5_vzalloc(*inlen);
+	*cqb = kvzalloc(*inlen, GFP_KERNEL);
 	if (!*cqb) {
 		err = -ENOMEM;
 		goto err_db;
@@ -884,7 +884,7 @@ static int create_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
 
 	*inlen = MLX5_ST_SZ_BYTES(create_cq_in) +
 		 MLX5_FLD_SZ_BYTES(create_cq_in, pas[0]) * cq->buf.buf.npages;
-	*cqb = mlx5_vzalloc(*inlen);
+	*cqb = kvzalloc(*inlen, GFP_KERNEL);
 	if (!*cqb) {
 		err = -ENOMEM;
 		goto err_buf;
@@ -1314,7 +1314,7 @@ int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
 	inlen = MLX5_ST_SZ_BYTES(modify_cq_in) +
 		MLX5_FLD_SZ_BYTES(modify_cq_in, pas[0]) * npas;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		goto ex_resize;
diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index f1b56de64871..95db929bdc34 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -218,7 +218,7 @@ static int process_pma_cmd(struct ib_device *ibdev, u8 port_num,
 			(struct ib_pma_portcounters_ext *)(out_mad->data + 40);
 		int sz = MLX5_ST_SZ_BYTES(query_vport_counter_out);
 
-		out_cnt = mlx5_vzalloc(sz);
+		out_cnt = kvzalloc(sz, GFP_KERNEL);
 		if (!out_cnt)
 			return IB_MAD_RESULT_FAILURE;
 
@@ -231,7 +231,7 @@ static int process_pma_cmd(struct ib_device *ibdev, u8 port_num,
 			(struct ib_pma_portcounters *)(out_mad->data + 40);
 		int sz = MLX5_ST_SZ_BYTES(ppcnt_reg);
 
-		out_cnt = mlx5_vzalloc(sz);
+		out_cnt = kvzalloc(sz, GFP_KERNEL);
 		if (!out_cnt)
 			return IB_MAD_RESULT_FAILURE;
 
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d45772da0963..b6991204e5df 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -2263,7 +2263,7 @@ static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
 	if (!is_valid_attr(dev->mdev, flow_attr))
 		return ERR_PTR(-EINVAL);
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	handler = kzalloc(sizeof(*handler), GFP_KERNEL);
 	if (!handler || !spec) {
 		err = -ENOMEM;
@@ -3456,7 +3456,7 @@ static int mlx5_ib_query_q_counters(struct mlx5_ib_dev *dev,
 	__be32 val;
 	int ret, i;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -3485,7 +3485,7 @@ static int mlx5_ib_query_cong_counters(struct mlx5_ib_dev *dev,
 	int ret, i;
 	int offset = port->cnts.num_q_counters;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 366433f71b58..763bb5b36144 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1110,7 +1110,7 @@ static struct mlx5_ib_mr *reg_create(struct ib_mr *ibmr, struct ib_pd *pd,
 
 	inlen = MLX5_ST_SZ_BYTES(create_mkey_in) +
 		sizeof(*pas) * ((npages + 1) / 2) * 2;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		goto err_1;
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 93959e1e43a3..d17aad0f54c0 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -823,7 +823,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 
 	*inlen = MLX5_ST_SZ_BYTES(create_qp_in) +
 		 MLX5_FLD_SZ_BYTES(create_qp_in, pas[0]) * ncont;
-	*in = mlx5_vzalloc(*inlen);
+	*in = kvzalloc(*inlen, GFP_KERNEL);
 	if (!*in) {
 		err = -ENOMEM;
 		goto err_umem;
@@ -931,7 +931,7 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	qp->sq.qend = mlx5_get_send_wqe(qp, qp->sq.wqe_cnt);
 	*inlen = MLX5_ST_SZ_BYTES(create_qp_in) +
 		 MLX5_FLD_SZ_BYTES(create_qp_in, pas[0]) * qp->buf.npages;
-	*in = mlx5_vzalloc(*inlen);
+	*in = kvzalloc(*inlen, GFP_KERNEL);
 	if (!*in) {
 		err = -ENOMEM;
 		goto err_buf;
@@ -1060,7 +1060,7 @@ static int create_raw_packet_qp_sq(struct mlx5_ib_dev *dev,
 		return err;
 
 	inlen = MLX5_ST_SZ_BYTES(create_sq_in) + sizeof(u64) * ncont;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		goto err_umem;
@@ -1140,7 +1140,7 @@ static int create_raw_packet_qp_rq(struct mlx5_ib_dev *dev,
 	u32 rq_pas_size = get_rq_pas_size(qpc);
 
 	inlen = MLX5_ST_SZ_BYTES(create_rq_in) + rq_pas_size;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1193,7 +1193,7 @@ static int create_raw_packet_qp_tir(struct mlx5_ib_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(create_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1372,7 +1372,7 @@ static int create_rss_raw_qp_tir(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp,
 	}
 
 	inlen = MLX5_ST_SZ_BYTES(create_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1633,7 +1633,7 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 		if (err)
 			return err;
 	} else {
-		in = mlx5_vzalloc(inlen);
+		in = kvzalloc(inlen, GFP_KERNEL);
 		if (!in)
 			return -ENOMEM;
 
@@ -2164,7 +2164,7 @@ static int modify_raw_packet_eth_prio(struct mlx5_core_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tis_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2189,7 +2189,7 @@ static int modify_raw_packet_tx_affinity(struct mlx5_core_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tis_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2434,7 +2434,7 @@ static int modify_raw_packet_qp_rq(struct mlx5_ib_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2479,7 +2479,7 @@ static int modify_raw_packet_qp_sq(struct mlx5_core_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_sq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -4294,7 +4294,7 @@ static int query_raw_packet_qp_sq_state(struct mlx5_ib_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(query_sq_out);
-	out = mlx5_vzalloc(inlen);
+	out = kvzalloc(inlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -4321,7 +4321,7 @@ static int query_raw_packet_qp_rq_state(struct mlx5_ib_dev *dev,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(query_rq_out);
-	out = mlx5_vzalloc(inlen);
+	out = kvzalloc(inlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -4625,7 +4625,7 @@ static int  create_rq(struct mlx5_ib_rwq *rwq, struct ib_pd *pd,
 	dev = to_mdev(pd->device);
 
 	inlen = MLX5_ST_SZ_BYTES(create_rq_in) + sizeof(u64) * rwq->rq_num_pas;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -4855,7 +4855,7 @@ struct ib_rwq_ind_table *mlx5_ib_create_rwq_ind_table(struct ib_device *device,
 		return ERR_PTR(-ENOMEM);
 
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		goto err;
@@ -4934,7 +4934,7 @@ int mlx5_ib_modify_wq(struct ib_wq *wq, struct ib_wq_attr *wq_attr,
 		return -EOPNOTSUPP;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 7cb145f9a6db..43707b101f47 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -127,7 +127,7 @@ static int create_srq_user(struct ib_pd *pd, struct mlx5_ib_srq *srq,
 		goto err_umem;
 	}
 
-	in->pas = mlx5_vzalloc(sizeof(*in->pas) * ncont);
+	in->pas = kvzalloc(sizeof(*in->pas) * ncont, GFP_KERNEL);
 	if (!in->pas) {
 		err = -ENOMEM;
 		goto err_umem;
@@ -189,7 +189,7 @@ static int create_srq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_srq *srq,
 	}
 
 	mlx5_ib_dbg(dev, "srq->buf.page_shift = %d\n", srq->buf.page_shift);
-	in->pas = mlx5_vzalloc(sizeof(*in->pas) * srq->buf.npages);
+	in->pas = kvzalloc(sizeof(*in->pas) * srq->buf.npages, GFP_KERNEL);
 	if (!in->pas) {
 		err = -ENOMEM;
 		goto err_buf;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index e94a9532e218..de40b6cfee95 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -405,7 +405,7 @@ static u64 cq_read_field(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 	u32 *out;
 	int err;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return param;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index c8a005326e30..f4017c06ddd2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -180,9 +180,8 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
-		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
 		err = -ENOMEM;
 		goto out;
 	}
@@ -237,7 +236,7 @@ static int arfs_create_groups(struct mlx5e_flow_table *ft,
 
 	ft->g = kcalloc(MLX5E_ARFS_NUM_GROUPS,
 			sizeof(*ft->g), GFP_KERNEL);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if  (!in || !ft->g) {
 		kvfree(ft->g);
 		kvfree(in);
@@ -481,9 +480,8 @@ static struct mlx5_flow_handle *arfs_add_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_table *ft;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
-		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
 		err = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index f1f17f7a3cd0..46e56ec4c26f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -65,7 +65,7 @@ static int mlx5e_create_mkey(struct mlx5_core_dev *mdev, u32 pdn,
 	u32 *in;
 	int err;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -147,7 +147,7 @@ int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb)
 
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		goto out;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ce7b09d72ff6..e0dd1048c966 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1045,7 +1045,7 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 	    (hfunc != ETH_RSS_HASH_TOP))
 		return -EINVAL;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 576d6787b484..936fc6d96c18 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -218,11 +218,9 @@ static int mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
-	if (!spec) {
-		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
+	if (!spec)
 		return -ENOMEM;
-	}
 
 	if (rule_type == MLX5E_VLAN_RULE_TYPE_MATCH_VID)
 		mlx5e_vport_context_update_vlans(priv);
@@ -660,11 +658,9 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
-	if (!spec) {
-		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
+	if (!spec)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	if (proto) {
 		spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
@@ -742,7 +738,7 @@ static int mlx5e_create_ttc_table_groups(struct mlx5e_ttc_table *ttc)
 			sizeof(*ft->g), GFP_KERNEL);
 	if (!ft->g)
 		return -ENOMEM;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		kfree(ft->g);
 		return -ENOMEM;
@@ -853,11 +849,9 @@ static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 	u8 *mc_dmac;
 	u8 *mv_dmac;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
-	if (!spec) {
-		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
+	if (!spec)
 		return -ENOMEM;
-	}
 
 	mc_dmac = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
 			       outer_headers.dmac_47_16);
@@ -917,7 +911,7 @@ static int mlx5e_create_l2_table_groups(struct mlx5e_l2_table *l2_table)
 	ft->g = kcalloc(MLX5E_NUM_L2_GROUPS, sizeof(*ft->g), GFP_KERNEL);
 	if (!ft->g)
 		return -ENOMEM;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		kfree(ft->g);
 		return -ENOMEM;
@@ -1072,7 +1066,7 @@ static int mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft)
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	int err;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 85bf4a389295..bdd82c9b3992 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -296,7 +296,7 @@ add_ethtool_flow_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_handle *rule;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec)
 		return ERR_PTR(-ENOMEM);
 	err = set_flow_attrs(spec->match_criteria, spec->match_value,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a61b71b6fff3..edc485e489cc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -252,9 +252,9 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	void *out;
 	u32 *in;
 
-	in = mlx5_vzalloc(sz);
+	in = kvzalloc(sz, GFP_KERNEL);
 	if (!in)
-		goto free_out;
+		return;
 
 	MLX5_SET(ppcnt_reg, in, local_port, 1);
 
@@ -288,7 +288,6 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 				     MLX5_REG_PPCNT, 0, 0);
 	}
 
-free_out:
 	kvfree(in);
 }
 
@@ -314,7 +313,7 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 	if (!MLX5_CAP_MCAM_FEATURE(mdev, pcie_performance_group))
 		return;
 
-	in = mlx5_vzalloc(sz);
+	in = kvzalloc(sz, GFP_KERNEL);
 	if (!in)
 		return;
 
@@ -503,7 +502,7 @@ static int mlx5e_create_umr_mkey(struct mlx5_core_dev *mdev,
 	if (!MLX5E_VALID_NUM_MTTS(npages))
 		return -EINVAL;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -711,7 +710,7 @@ static int mlx5e_create_rq(struct mlx5e_rq *rq,
 
 	inlen = MLX5_ST_SZ_BYTES(create_rq_in) +
 		sizeof(u64) * rq->wq_ctrl.buf.npages;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -748,7 +747,7 @@ static int mlx5e_modify_rq_state(struct mlx5e_rq *rq, int curr_state,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -776,7 +775,7 @@ static int mlx5e_modify_rq_scatter_fcs(struct mlx5e_rq *rq, bool enable)
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -805,7 +804,7 @@ static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1134,7 +1133,7 @@ static int mlx5e_create_sq(struct mlx5_core_dev *mdev,
 
 	inlen = MLX5_ST_SZ_BYTES(create_sq_in) +
 		sizeof(u64) * csp->wq_ctrl->buf.npages;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1182,7 +1181,7 @@ static int mlx5e_modify_sq(struct mlx5_core_dev *mdev, u32 sqn,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_sq_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -1496,7 +1495,7 @@ static int mlx5e_create_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 	inlen = MLX5_ST_SZ_BYTES(create_cq_in) +
 		sizeof(u64) * cq->wq_ctrl.frag_buf.npages;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2091,7 +2090,7 @@ mlx5e_create_rqt(struct mlx5e_priv *priv, int sz, struct mlx5e_rqt *rqt)
 	int i;
 
 	inlen = MLX5_ST_SZ_BYTES(create_rqt_in) + sizeof(u32) * sz;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2210,7 +2209,7 @@ int mlx5e_redirect_rqt(struct mlx5e_priv *priv, u32 rqtn, int sz,
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_rqt_in) + sizeof(u32) * sz;
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2433,7 +2432,7 @@ static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 	int ix;
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2850,7 +2849,7 @@ int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv)
 	int tt;
 
 	inlen = MLX5_ST_SZ_BYTES(create_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -2889,7 +2888,7 @@ int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
 	int ix;
 
 	inlen = MLX5_ST_SZ_BYTES(create_tir_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 11c27e4fadf6..66a9bd635176 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1738,7 +1738,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	}
 
 	flow = kzalloc(sizeof(*flow) + attr_size, GFP_KERNEL);
-	parse_attr = mlx5_vzalloc(sizeof(*parse_attr));
+	parse_attr = kvzalloc(sizeof(*parse_attr), GFP_KERNEL);
 	if (!parse_attr || !flow) {
 		err = -ENOMEM;
 		goto err_free;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index ea5d8d37a75c..df0034d8f48c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -548,7 +548,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	inlen = MLX5_ST_SZ_BYTES(create_eq_in) +
 		MLX5_FLD_SZ_BYTES(create_eq_in, pas[0]) * eq->buf.npages;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		goto err_buf;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 2e34d95ea776..81dfcd90b1f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -248,11 +248,10 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 	if (rx_rule)
 		match_header |= MLX5_MATCH_MISC_PARAMETERS;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
-	if (!spec) {
-		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
+	if (!spec)
 		return NULL;
-	}
+
 	dmac_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
 			      outer_headers.dmac_47_16);
 	dmac_c = MLX5_ADDR_OF(fte_match_param, spec->match_criteria,
@@ -350,10 +349,9 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 		return -EOPNOTSUPP;
 	}
 
-	flow_group_in = mlx5_vzalloc(inlen);
+	flow_group_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!flow_group_in)
 		return -ENOMEM;
-	memset(flow_group_in, 0, inlen);
 
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
@@ -961,7 +959,7 @@ static int esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 		return -EOPNOTSUPP;
 	}
 
-	flow_group_in = mlx5_vzalloc(inlen);
+	flow_group_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!flow_group_in)
 		return -ENOMEM;
 
@@ -1078,7 +1076,7 @@ static int esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 		return -EOPNOTSUPP;
 	}
 
-	flow_group_in = mlx5_vzalloc(inlen);
+	flow_group_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!flow_group_in)
 		return -ENOMEM;
 
@@ -1241,11 +1239,9 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 		  "vport[%d] configure ingress rules, vlan(%d) qos(%d)\n",
 		  vport->vport, vport->info.vlan, vport->info.qos);
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
 		err = -ENOMEM;
-		esw_warn(esw->dev, "vport[%d] configure ingress rules failed, err(%d)\n",
-			 vport->vport, err);
 		goto out;
 	}
 
@@ -1322,11 +1318,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 		  "vport[%d] configure egress rules, vlan(%d) qos(%d)\n",
 		  vport->vport, vport->info.vlan, vport->info.qos);
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
 		err = -ENOMEM;
-		esw_warn(esw->dev, "vport[%d] configure egress rules failed, err(%d)\n",
-			 vport->vport, err);
 		goto out;
 	}
 
@@ -2158,7 +2152,7 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 	if (!LEGAL_VPORT(esw, vport))
 		return -EINVAL;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index f991f669047e..3795943ef2d1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -311,9 +311,8 @@ mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn
 	struct mlx5_flow_spec *spec;
 	void *misc;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
-		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
 		flow_rule = ERR_PTR(-ENOMEM);
 		goto out;
 	}
@@ -401,9 +400,8 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 	struct mlx5_flow_spec *spec;
 	int err = 0;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
-		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
 		err = -ENOMEM;
 		goto out;
 	}
@@ -488,7 +486,7 @@ static int esw_create_offloads_fdb_tables(struct mlx5_eswitch *esw, int nvports)
 	u32 *flow_group_in;
 
 	esw_debug(esw->dev, "Create offloads FDB Tables\n");
-	flow_group_in = mlx5_vzalloc(inlen);
+	flow_group_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!flow_group_in)
 		return -ENOMEM;
 
@@ -631,7 +629,7 @@ static int esw_create_vport_rx_group(struct mlx5_eswitch *esw)
 	int err = 0;
 	int nvports = priv->sriov.num_vfs + 2;
 
-	flow_group_in = mlx5_vzalloc(inlen);
+	flow_group_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!flow_group_in)
 		return -ENOMEM;
 
@@ -675,9 +673,8 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 	struct mlx5_flow_spec *spec;
 	void *misc;
 
-	spec = mlx5_vzalloc(sizeof(*spec));
+	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec) {
-		esw_warn(esw->dev, "Failed to alloc match parameters\n");
 		flow_rule = ERR_PTR(-ENOMEM);
 		goto out;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 19e3d2fc2099..b27c59af9640 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -235,11 +235,9 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	u32 *in;
 	int err;
 
-	in = mlx5_vzalloc(inlen);
-	if (!in) {
-		mlx5_core_warn(dev, "failed to allocate inbox\n");
+	in = kvzalloc(inlen, GFP_KERNEL);
+	if (!in)
 		return -ENOMEM;
-	}
 
 	MLX5_SET(set_fte_in, in, opcode, MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY);
 	MLX5_SET(set_fte_in, in, op_mod, opmod);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index b8a176503d38..20a50f23fb1b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -376,11 +376,9 @@ static void del_rule(struct fs_node *node)
 	int err;
 	bool update_fte = false;
 
-	match_value = mlx5_vzalloc(match_len);
-	if (!match_value) {
-		mlx5_core_warn(dev, "failed to allocate inbox\n");
+	match_value = kvzalloc(match_len, GFP_KERNEL);
+	if (!match_value)
 		return;
-	}
 
 	fs_get_obj(rule, node);
 	fs_get_obj(fte, rule->node.parent);
@@ -1159,7 +1157,7 @@ static struct mlx5_flow_group *create_autogroup(struct mlx5_flow_table *ft,
 	if (!ft->autogroup.active)
 		return ERR_PTR(-ENOENT);
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return ERR_PTR(-ENOMEM);
 
@@ -1778,7 +1776,7 @@ static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_flow_steering
 	struct mlx5_flow_namespace *ns;
 
 	/* Create the root namespace */
-	root_ns = mlx5_vzalloc(sizeof(*root_ns));
+	root_ns = kvzalloc(sizeof(*root_ns), GFP_KERNEL);
 	if (!root_ns)
 		return NULL;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 019c230da498..9b397fe3f159 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -98,7 +98,7 @@ static int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core
 	void *qpc;
 
 	inlen = MLX5_ST_SZ_BYTES(create_qp_in);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index a57d5a81eb05..efcded7ca27a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -279,7 +279,7 @@ static int give_pages(struct mlx5_core_dev *dev, u16 func_id, int npages,
 	int i;
 
 	inlen += npages * MLX5_FLD_SZ_BYTES(manage_pages_in, pas[0]);
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		mlx5_core_warn(dev, "vzalloc failed %d\n", inlen);
@@ -376,7 +376,7 @@ static int reclaim_pages(struct mlx5_core_dev *dev, u32 func_id, int npages,
 		*nclaimed = 0;
 
 	outlen += npages * MLX5_FLD_SZ_BYTES(manage_pages_out, pas[0]);
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 141583daf5a2..1975d4388d4f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -47,8 +47,8 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 	u32 *in = NULL;
 	void *data;
 
-	in = mlx5_vzalloc(inlen);
-	out = mlx5_vzalloc(outlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!in || !out)
 		goto out;
 
@@ -454,7 +454,7 @@ int mlx5_core_query_ib_ppcnt(struct mlx5_core_dev *dev,
 	u32 *in;
 	int err;
 
-	in  = mlx5_vzalloc(sz);
+	in  = kvzalloc(sz, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index cbbcef2884be..573a6b27fed8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -527,7 +527,7 @@ int mlx5_core_query_out_of_buffer(struct mlx5_core_dev *dev, u16 counter_id,
 	void *out;
 	int err;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
index 3099630015d7..f774de6f5fcb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -162,7 +162,7 @@ static int create_srq_cmd(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 
 	pas_size  = get_pas_size(in);
 	inlen	  = MLX5_ST_SZ_BYTES(create_srq_in) + pas_size;
-	create_in = mlx5_vzalloc(inlen);
+	create_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!create_in)
 		return -ENOMEM;
 
@@ -221,7 +221,7 @@ static int query_srq_cmd(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 	void *srqc;
 	int err;
 
-	srq_out = mlx5_vzalloc(MLX5_ST_SZ_BYTES(query_srq_out));
+	srq_out = kvzalloc(MLX5_ST_SZ_BYTES(query_srq_out), GFP_KERNEL);
 	if (!srq_out)
 		return -ENOMEM;
 
@@ -256,7 +256,7 @@ static int create_xrc_srq_cmd(struct mlx5_core_dev *dev,
 
 	pas_size  = get_pas_size(in);
 	inlen	  = MLX5_ST_SZ_BYTES(create_xrc_srq_in) + pas_size;
-	create_in = mlx5_vzalloc(inlen);
+	create_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!create_in)
 		return -ENOMEM;
 
@@ -320,7 +320,7 @@ static int query_xrc_srq_cmd(struct mlx5_core_dev *dev,
 	void *xrc_srqc;
 	int err;
 
-	xrcsrq_out = mlx5_vzalloc(MLX5_ST_SZ_BYTES(query_xrc_srq_out));
+	xrcsrq_out = kvzalloc(MLX5_ST_SZ_BYTES(query_xrc_srq_out), GFP_KERNEL);
 	if (!xrcsrq_out)
 		return -ENOMEM;
 	memset(xrcsrq_in, 0, sizeof(xrcsrq_in));
@@ -357,7 +357,7 @@ static int create_rmp_cmd(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 
 	pas_size = get_pas_size(in);
 	inlen = MLX5_ST_SZ_BYTES(create_rmp_in) + pas_size;
-	create_in = mlx5_vzalloc(inlen);
+	create_in = kvzalloc(inlen, GFP_KERNEL);
 	if (!create_in)
 		return -ENOMEM;
 
@@ -390,7 +390,7 @@ static int arm_rmp_cmd(struct mlx5_core_dev *dev,
 	void *bitmask;
 	int err;
 
-	in = mlx5_vzalloc(MLX5_ST_SZ_BYTES(modify_rmp_in));
+	in = kvzalloc(MLX5_ST_SZ_BYTES(modify_rmp_in), GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -417,7 +417,7 @@ static int query_rmp_cmd(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 	void *rmpc;
 	int err;
 
-	rmp_out =  mlx5_vzalloc(MLX5_ST_SZ_BYTES(query_rmp_out));
+	rmp_out =  kvzalloc(MLX5_ST_SZ_BYTES(query_rmp_out), GFP_KERNEL);
 	if (!rmp_out)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index a00ff49eec18..5e128d7a9ffd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -284,7 +284,7 @@ int mlx5_core_arm_rmp(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm)
 	void *bitmask;
 	int  err;
 
-	in = mlx5_vzalloc(MLX5_ST_SZ_BYTES(modify_rmp_in));
+	in = kvzalloc(MLX5_ST_SZ_BYTES(modify_rmp_in), GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 15c2294dd2b4..06019d00ab7b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -172,7 +172,7 @@ int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 	u8 *out_addr;
 	int err;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -197,11 +197,9 @@ int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 	void *nic_vport_ctx;
 	u8 *perm_mac;
 
-	in = mlx5_vzalloc(inlen);
-	if (!in) {
-		mlx5_core_warn(mdev, "failed to allocate inbox\n");
+	in = kvzalloc(inlen, GFP_KERNEL);
+	if (!in)
 		return -ENOMEM;
-	}
 
 	MLX5_SET(modify_nic_vport_context_in, in,
 		 field_select.permanent_address, 1);
@@ -231,7 +229,7 @@ int mlx5_query_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 *mtu)
 	u32 *out;
 	int err;
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -251,7 +249,7 @@ int mlx5_modify_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 mtu)
 	void *in;
 	int err;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -501,7 +499,7 @@ int mlx5_query_nic_vport_system_image_guid(struct mlx5_core_dev *mdev,
 	u32 *out;
 	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -521,7 +519,7 @@ int mlx5_query_nic_vport_node_guid(struct mlx5_core_dev *mdev, u64 *node_guid)
 	u32 *out;
 	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -551,7 +549,7 @@ int mlx5_modify_nic_vport_node_guid(struct mlx5_core_dev *mdev,
 	if (!MLX5_CAP_ESW(mdev, nic_vport_node_guid_modify))
 		return -EOPNOTSUPP;
 
-	in = mlx5_vzalloc(inlen);
+	in = kvzalloc(inlen, GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
 
@@ -577,7 +575,7 @@ int mlx5_query_nic_vport_qkey_viol_cntr(struct mlx5_core_dev *mdev,
 	u32 *out;
 	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
 
-	out = mlx5_vzalloc(outlen);
+	out = kvzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
@@ -879,11 +877,9 @@ int mlx5_modify_nic_vport_promisc(struct mlx5_core_dev *mdev,
 	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
 	int err;
 
-	in = mlx5_vzalloc(inlen);
-	if (!in) {
-		mlx5_core_err(mdev, "failed to allocate inbox\n");
+	in = kvzalloc(inlen, GFP_KERNEL);
+	if (!in)
 		return -ENOMEM;
-	}
 
 	MLX5_SET(modify_nic_vport_context_in, in, field_select.promisc, 1);
 	MLX5_SET(modify_nic_vport_context_in, in,
@@ -913,11 +909,9 @@ static int mlx5_nic_vport_update_roce_state(struct mlx5_core_dev *mdev,
 	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
 	int err;
 
-	in = mlx5_vzalloc(inlen);
-	if (!in) {
-		mlx5_core_warn(mdev, "failed to allocate inbox\n");
+	in = kvzalloc(inlen, GFP_KERNEL);
+	if (!in)
 		return -ENOMEM;
-	}
 
 	MLX5_SET(modify_nic_vport_context_in, in, field_select.roce_en, 1);
 	MLX5_SET(modify_nic_vport_context_in, in, nic_vport_context.roce_en,
@@ -952,7 +946,7 @@ int mlx5_core_query_vport_counter(struct mlx5_core_dev *dev, u8 other_vport,
 	int	err;
 
 	is_group_manager = MLX5_CAP_GEN(dev, vport_group_manager);
-	in = mlx5_vzalloc(in_sz);
+	in = kvzalloc(in_sz, GFP_KERNEL);
 	if (!in) {
 		err = -ENOMEM;
 		return err;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index bcdf739ee41a..c2740688d679 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -890,11 +890,6 @@ static inline u16 cmdif_rev(struct mlx5_core_dev *dev)
 	return ioread32be(&dev->iseg->cmdif_rev_fw_sub) >> 16;
 }
 
-static inline void *mlx5_vzalloc(unsigned long size)
-{
-	return kvzalloc(size, GFP_KERNEL);
-}
-
 static inline u32 mlx5_base_mkey(const u32 key)
 {
 	return key & 0xffffff00u;
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
