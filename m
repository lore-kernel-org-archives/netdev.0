From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next V2 02/10] IB/mlx5: Fix error handling order in create_kernel_qp
Date: Sun,  8 Jan 2017 17:54:43 +0200
Message-ID: <1483890891-8767-3-git-send-email-saeedm@mellanox.com>
References: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57463 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753220AbdAHPy6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 10:54:58 -0500
In-Reply-To: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Make sure order of cleanup is exactly the opposite of initialization.

Fixes: 9603b61de1ee ('mlx5: Move pci device handling from mlx5_ib to mlx5_core')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 53f4dd3..42d021cd 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -994,12 +994,12 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	return 0;
 
 err_wrid:
-	mlx5_db_free(dev->mdev, &qp->db);
 	kfree(qp->sq.wqe_head);
 	kfree(qp->sq.w_list);
 	kfree(qp->sq.wrid);
 	kfree(qp->sq.wr_data);
 	kfree(qp->rq.wrid);
+	mlx5_db_free(dev->mdev, &qp->db);
 
 err_free:
 	kvfree(*in);
@@ -1014,12 +1014,12 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 
 static void destroy_qp_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 {
-	mlx5_db_free(dev->mdev, &qp->db);
 	kfree(qp->sq.wqe_head);
 	kfree(qp->sq.w_list);
 	kfree(qp->sq.wrid);
 	kfree(qp->sq.wr_data);
 	kfree(qp->rq.wrid);
+	mlx5_db_free(dev->mdev, &qp->db);
 	mlx5_buf_free(dev->mdev, &qp->buf);
 	free_uuar(&dev->mdev->priv.uuari, qp->bf->uuarn);
 }
-- 
2.7.4
