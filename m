From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 02/10] IB/mlx5: Add support for extended query device
Date: Wed, 13 Aug 2014 14:39:03 +0300
Message-ID: <1407929951-16362-3-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:45004 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaHMLjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:36 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so644858wib.2
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:35 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new entry for query device extended which currently has identical
functionality to query_device and publish support for it.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d8907b20522a..63fddeec90af 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -151,8 +151,8 @@ static void free_comp_eqs(struct mlx5_ib_dev *dev)
 	spin_unlock(&table->lock);
 }
 
-static int mlx5_ib_query_device(struct ib_device *ibdev,
-				struct ib_device_attr *props)
+static int query_device(struct ib_device *ibdev,
+			struct ib_device_attr *props)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
 	struct ib_smp *in_mad  = NULL;
@@ -248,6 +248,12 @@ out:
 	return err;
 }
 
+static int mlx5_ib_query_device(struct ib_device *ibdev,
+				struct ib_device_attr *props)
+{
+	return query_device(ibdev, props);
+}
+
 int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
 		       struct ib_port_attr *props)
 {
@@ -775,6 +781,17 @@ static int mlx5_ib_dealloc_pd(struct ib_pd *pd)
 	return 0;
 }
 
+static int mlx5_ib_query_device_ex(struct ib_device *device,
+				   struct ib_device_attr *attr,
+				   struct ib_udata *uhw)
+{
+	int err;
+
+	err = query_device(device, attr);
+
+	return err;
+}
+
 static int mlx5_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibqp->device);
@@ -1354,6 +1371,10 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.alloc_fast_reg_page_list = mlx5_ib_alloc_fast_reg_page_list;
 	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
+	dev->ib_dev.ex_query_device	= mlx5_ib_query_device_ex;
+
+	dev->ib_dev.uverbs_ex_cmd_mask	|=
+		(1ull << IB_USER_VERBS_EX_CMD_QUERY_DEVICE);
 
 	if (mdev->caps.flags & MLX5_DEV_CAP_FLAG_XRC) {
 		dev->ib_dev.alloc_xrcd = mlx5_ib_alloc_xrcd;
-- 
1.9.3
