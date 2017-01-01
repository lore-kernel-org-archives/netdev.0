From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 02/11] IB/mlx5: Reorder code in query device command
Date: Sun,  1 Jan 2017 23:10:18 +0200
Message-ID: <1483305027-2573-3-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

The order of features exposed by private mlx5-abi.h
file is CQE zipping, packet pacing and multi-packet WQE.

The internal order implemented in mlx5_ib_query_device() is
multi-packet WQE, CQE zipping and packet pacing.

Such difference hurts code readability, so let's sync,
while mlx5-abi.h (exposed to userspace) is the primary
order.

This commit doesn't change any functionality.

Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d566f67..2ab4e32 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -672,17 +672,6 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 			1 << MLX5_CAP_GEN(dev->mdev, log_max_rq);
 	}
 
-	if (field_avail(typeof(resp), mlx5_ib_support_multi_pkt_send_wqes,
-			uhw->outlen)) {
-		resp.mlx5_ib_support_multi_pkt_send_wqes =
-			MLX5_CAP_ETH(mdev, multi_pkt_send_wqe);
-		resp.response_length +=
-			sizeof(resp.mlx5_ib_support_multi_pkt_send_wqes);
-	}
-
-	if (field_avail(typeof(resp), reserved, uhw->outlen))
-		resp.response_length += sizeof(resp.reserved);
-
 	if (field_avail(typeof(resp), cqe_comp_caps, uhw->outlen)) {
 		resp.cqe_comp_caps.max_num =
 			MLX5_CAP_GEN(dev->mdev, cqe_compression) ?
@@ -706,6 +695,17 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 		resp.response_length += sizeof(resp.packet_pacing_caps);
 	}
 
+	if (field_avail(typeof(resp), mlx5_ib_support_multi_pkt_send_wqes,
+			uhw->outlen)) {
+		resp.mlx5_ib_support_multi_pkt_send_wqes =
+			MLX5_CAP_ETH(mdev, multi_pkt_send_wqe);
+		resp.response_length +=
+			sizeof(resp.mlx5_ib_support_multi_pkt_send_wqes);
+	}
+
+	if (field_avail(typeof(resp), reserved, uhw->outlen))
+		resp.response_length += sizeof(resp.reserved);
+
 	if (uhw->outlen) {
 		err = ib_copy_to_udata(uhw, &resp, resp.response_length);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
