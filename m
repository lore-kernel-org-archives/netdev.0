From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 08/12] net/mlx5_core: Modify CQ moderation parameters
Date: Tue, 14 Apr 2015 11:20:31 +0300
Message-ID: <1428999635-15025-9-git-send-email-amirv@mellanox.com>
References: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:41991 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751664AbbDNIVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:21:30 -0400
In-Reply-To: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cq.c | 18 ++++++++++++++++++
 include/linux/mlx5/cq.h                      |  3 +++
 2 files changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
index eb0cf81..04ab7e4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
@@ -219,6 +219,24 @@ int mlx5_core_modify_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 }
 EXPORT_SYMBOL(mlx5_core_modify_cq);
 
+int mlx5_core_modify_cq_moderation(struct mlx5_core_dev *dev,
+				   struct mlx5_core_cq *cq,
+				   u16 cq_period,
+				   u16 cq_max_count)
+{
+	struct mlx5_modify_cq_mbox_in in;
+
+	memset(&in, 0, sizeof(in));
+
+	in.cqn              = cpu_to_be32(cq->cqn);
+	in.ctx.cq_period    = cpu_to_be16(cq_period);
+	in.ctx.cq_max_count = cpu_to_be16(cq_max_count);
+	in.field_select     = cpu_to_be32(MLX5_CQ_MODIFY_PERIOD |
+					  MLX5_CQ_MODIFY_COUNT);
+
+	return mlx5_core_modify_cq(dev, cq, &in, sizeof(in));
+}
+
 int mlx5_init_cq_table(struct mlx5_core_dev *dev)
 {
 	struct mlx5_cq_table *table = &dev->priv.cq_table;
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index 2695ced..abc4767 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -169,6 +169,9 @@ int mlx5_core_query_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 		       struct mlx5_query_cq_mbox_out *out);
 int mlx5_core_modify_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 			struct mlx5_modify_cq_mbox_in *in, int in_sz);
+int mlx5_core_modify_cq_moderation(struct mlx5_core_dev *dev,
+				   struct mlx5_core_cq *cq, u16 cq_period,
+				   u16 cq_max_count);
 int mlx5_debug_cq_add(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
 void mlx5_debug_cq_remove(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
 
-- 
1.9.3
