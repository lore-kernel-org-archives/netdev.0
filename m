From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] mlx4_en: remove unnecessary error check
Date: Mon, 24 Jul 2017 04:22:44 -0400
Message-ID: <1500884564-310-1-git-send-email-yanjun.zhu@oracle.com>
To: tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com, leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37021 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdGXIUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 04:20:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function mlx4_en_get_profile always return zero. So it is not
necessary to check its return value.

CC: Joe Jin <joe.jin@oracle.com>
CC: Junxiao Bi <junxiao.bi@oracle.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 2b0cbca..686e18d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -147,7 +147,7 @@ void mlx4_en_update_loopback_state(struct net_device *dev,
 	mutex_unlock(&priv->mdev->state_lock);
 }
 
-static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
+static void mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_en_profile *params = &mdev->profile;
 	int i;
@@ -176,8 +176,6 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].rss_rings = 0;
 		params->prof[i].inline_thold = inline_thold;
 	}
-
-	return 0;
 }
 
 static void *mlx4_en_get_netdev(struct mlx4_dev *dev, void *ctx, u8 port)
@@ -309,10 +307,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	}
 
 	/* Build device profile according to supplied module parameters */
-	if (mlx4_en_get_profile(mdev)) {
-		mlx4_err(mdev, "Bad module parameters, aborting\n");
-		goto err_mr;
-	}
+	mlx4_en_get_profile(mdev);
 
 	/* Configure which ports to start according to module parameters */
 	mdev->port_cnt = 0;
-- 
2.7.4
