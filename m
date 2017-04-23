From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/7] net/mlx5: Fix driver load bad flow when having fw initializing timeout
Date: Sun, 23 Apr 2017 13:07:56 +0300
Message-ID: <20170423100802.27630-2-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48686 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044738AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

If FW is stuck in initializing state we will skip the driver load, but
current error handling flow doesn't clean previously allocated command
interface resources.

Fixes: e3297246c2c8 ('net/mlx5_core: Wait for FW readiness on startup')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 60154a175bd3..0ad66324247f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1029,7 +1029,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	if (err) {
 		dev_err(&dev->pdev->dev, "Firmware over %d MS in initializing state, aborting\n",
 			FW_INIT_TIMEOUT_MILI);
-		goto out_err;
+		goto err_cmd_cleanup;
 	}
 
 	err = mlx5_core_enable_hca(dev, 0);
-- 
2.11.0
