From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/3] net/mlx5: Fix driver load error flow when firmware is stuck
Date: Fri, 30 Jun 2017 10:12:27 +0300
Message-ID: <20170630071229.20357-2-saeedm@mellanox.com>
References: <20170630071229.20357-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44947 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751743AbdF3HNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 03:13:39 -0400
In-Reply-To: <20170630071229.20357-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

When wait for firmware init fails, previous code would mistakenly
return success and cause inconsistency in the driver state.

Fixes: 6c780a0267b8 ("net/mlx5: Wait for FW readiness before initializing command interface")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 13be264587f1..fd47b5134841 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1020,7 +1020,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	if (err) {
 		dev_err(&dev->pdev->dev, "Firmware over %d MS in pre-initializing state, aborting\n",
 			FW_PRE_INIT_TIMEOUT_MILI);
-		goto out;
+		goto out_err;
 	}
 
 	err = mlx5_cmd_init(dev);
-- 
2.11.0
