From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net-next] mlx5: remove dead code
Date: Sun, 29 Dec 2013 13:51:37 -0800
Message-ID: <20131229135137.7a8566da@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eli Cohen <eli@mellanox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:15312 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424Ab3L2Vvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 16:51:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 3 functions in the mlx5 driver which are used and should be
deleted. Upstream is not the repository to hold old dead code, or code
which is used by outside drivers, or code intended for future undetermined
features.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c	2013-10-06 14:48:23.738461842 -0700
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c	2013-12-29 13:40:54.666481807 -0800
@@ -199,13 +199,6 @@ int mlx5_core_query_cq(struct mlx5_core_
 }
 EXPORT_SYMBOL(mlx5_core_query_cq);
 
-
-int mlx5_core_modify_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
-			int type, struct mlx5_cq_modify_params *params)
-{
-	return -ENOSYS;
-}
-
 int mlx5_init_cq_table(struct mlx5_core_dev *dev)
 {
 	struct mlx5_cq_table *table = &dev->priv.cq_table;
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c	2013-12-05 14:47:25.812499721 -0800
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mr.c	2013-12-29 13:40:05.899556889 -0800
@@ -98,49 +98,3 @@ int mlx5_core_destroy_mkey(struct mlx5_c
 	return err;
 }
 EXPORT_SYMBOL(mlx5_core_destroy_mkey);
-
-int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
-			 struct mlx5_query_mkey_mbox_out *out, int outlen)
-{
-	struct mlx5_destroy_mkey_mbox_in in;
-	int err;
-
-	memset(&in, 0, sizeof(in));
-	memset(out, 0, outlen);
-
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_MKEY);
-	in.mkey = cpu_to_be32(mlx5_mkey_to_idx(mr->key));
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
-	if (err)
-		return err;
-
-	if (out->hdr.status)
-		return mlx5_cmd_status_to_err(&out->hdr);
-
-	return err;
-}
-EXPORT_SYMBOL(mlx5_core_query_mkey);
-
-int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
-			     u32 *mkey)
-{
-	struct mlx5_query_special_ctxs_mbox_in in;
-	struct mlx5_query_special_ctxs_mbox_out out;
-	int err;
-
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		return mlx5_cmd_status_to_err(&out.hdr);
-
-	*mkey = be32_to_cpu(out.dump_fill_mkey);
-
-	return err;
-}
-EXPORT_SYMBOL(mlx5_core_dump_fill_mkey);
--- a/include/linux/mlx5/cq.h	2013-10-06 14:48:24.762451839 -0700
+++ b/include/linux/mlx5/cq.h	2013-12-29 13:40:47.454639349 -0800
@@ -157,8 +157,6 @@ int mlx5_core_create_cq(struct mlx5_core
 int mlx5_core_destroy_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
 int mlx5_core_query_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 		       struct mlx5_query_cq_mbox_out *out);
-int mlx5_core_modify_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
-			int type, struct mlx5_cq_modify_params *params);
 int mlx5_debug_cq_add(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
 void mlx5_debug_cq_remove(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq);
 
--- a/include/linux/mlx5/driver.h	2013-12-05 14:47:26.036496073 -0800
+++ b/include/linux/mlx5/driver.h	2013-12-29 13:40:10.647451164 -0800
@@ -687,10 +687,6 @@ int mlx5_core_create_mkey(struct mlx5_co
 			  mlx5_cmd_cbk_t callback, void *context,
 			  struct mlx5_create_mkey_mbox_out *out);
 int mlx5_core_destroy_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr);
-int mlx5_core_query_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
-			 struct mlx5_query_mkey_mbox_out *out, int outlen);
-int mlx5_core_dump_fill_mkey(struct mlx5_core_dev *dev, struct mlx5_core_mr *mr,
-			     u32 *mkey);
 int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn);
 int mlx5_core_dealloc_pd(struct mlx5_core_dev *dev, u32 pdn);
 int mlx5_core_mad_ifc(struct mlx5_core_dev *dev, void *inb, void *outb,
