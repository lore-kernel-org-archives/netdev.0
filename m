From: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 3.11-rc1] mlx5 core: Fix __udivdi3 when compiling for 32 bit arches
Date: Mon, 15 Jul 2013 08:56:45 -0600
Message-ID: <1373900205-69711-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index 4273c06..9c7194b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -156,7 +156,7 @@ static ssize_t average_read(struct file *filp, char __user *buf, size_t count,
 	stats = filp->private_data;
 	spin_lock(&stats->lock);
 	if (stats->n)
-		field = stats->sum / stats->n;
+		field = div64_u64(stats->sum, stats->n);
 	spin_unlock(&stats->lock);
 	ret = snprintf(tbuf, sizeof(tbuf), "%llu\n", field);
 	if (ret > 0) {
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
