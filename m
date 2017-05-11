From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net/mlx4_core: Use min_t instead of if for consistency
Date: Thu, 11 May 2017 11:20:52 +0300
Message-ID: <1494490852-5567-1-git-send-email-yuval.shaia@oracle.com>
To: yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7032054..a58b15a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2862,12 +2862,11 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int port = 0;
 
 	if (msi_x) {
-		int nreq = dev->caps.num_ports * num_online_cpus() + 1;
+		int nreq = min_t(int,
+				 dev->caps.num_ports * num_online_cpus() + 1,
+				 dev->caps.num_eqs - dev->caps.reserved_eqs);
 
-		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
-			     nreq);
-		if (nreq > MAX_MSIX)
-			nreq = MAX_MSIX;
+		nreq = min_t(nreq, MAX_MSIX);
 
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
