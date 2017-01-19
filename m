From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/15] net/mlx5: Remove information print after attempt to load mlx5_ib module
Date: Fri, 20 Jan 2017 00:38:54 +0200
Message-ID: <20170119223908.15924-2-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59325 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751240AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Infiniband part of mlx5 driver can be compiled as a module
or as a part of bzImage (compiled in). In the second case,
the call to request_module will return an error -ENOENT.
It will cause to a misleading print "failed request module
on mlx5_ib".

This patch removes this print, In order to comply with mlx4.

Fixes: f66f049fb738 ("net/mlx5_core: Request the mlx5 IB module on driver load")
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 8701e85daf1c..5d160f33bc17 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1340,9 +1340,7 @@ static int init_one(struct pci_dev *pdev,
 		goto clean_health;
 	}
 
-	err = request_module_nowait(MLX5_IB_MOD);
-	if (err)
-		pr_info("failed request module on %s\n", MLX5_IB_MOD);
+	request_module_nowait(MLX5_IB_MOD);
 
 	err = devlink_register(devlink, &pdev->dev);
 	if (err)
-- 
2.11.0
