From: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] net/mlx5: clean function declarations in eswitch.c up
Date: Sun, 18 Sep 2016 16:44:22 +0800
Message-ID: <1474188262-9929-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        xie.baoyou-Th6q7B73Y6EnDS1+zs4M5A@public.gmane.org
To: matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c:463:5: warning: no previous prototype for 'esw_offloads_init' [-Wmissing-prototypes]
drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c:521:6: warning: no previous prototype for 'esw_offloads_cleanup' [-Wmissing-prototypes]

In fact, both functions are declared in
drivers/net/ethernet/mellanox/mlx5/core/eswitch.c,but should be
declared in a header file, thus can be recognized in other file.

So this patch moves the declarations into
drivers/net/ethernet/mellanox/mlx5/core/eswitch.h

Signed-off-by: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 3 ---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 1014305..b453cb6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -81,9 +81,6 @@ enum {
 			    MC_ADDR_CHANGE | \
 			    PROMISC_CHANGE)
 
-int esw_offloads_init(struct mlx5_eswitch *esw, int nvports);
-void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports);
-
 static int arm_vport_context_events_cmd(struct mlx5_core_dev *dev, u16 vport,
 					u32 events_mask)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index a961409..3bc5336 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -201,6 +201,9 @@ struct mlx5_eswitch {
 	int                     mode;
 };
 
+void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports);
+int esw_offloads_init(struct mlx5_eswitch *esw, int nvports);
+
 /* E-Switch API */
 int mlx5_eswitch_init(struct mlx5_core_dev *dev);
 void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
