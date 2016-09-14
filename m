From: Sebastian Ott <sebott-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] net/mlx4_en: fix off by one in error handling
Date: Wed, 14 Sep 2016 13:09:24 +0200 (CEST)
Message-ID: <alpine.LFD.2.20.1609141305360.1727@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If an error occurs in mlx4_init_eq_table the index used in the
err_out_unmap label is one too big which results in a panic in
mlx4_free_eq. This patch fixes the index in the error path.

Signed-off-by: Sebastian Ott <sebott-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index f613977..cf8f8a7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1305,8 +1305,8 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	return 0;
 
 err_out_unmap:
-	while (i >= 0)
-		mlx4_free_eq(dev, &priv->eq_table.eq[i--]);
+	while (i > 0)
+		mlx4_free_eq(dev, &priv->eq_table.eq[--i]);
 #ifdef CONFIG_RFS_ACCEL
 	for (i = 1; i <= dev->caps.num_ports; i++) {
 		if (mlx4_priv(dev)->port[i].rmap) {
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
