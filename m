From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 05/11] net/mlx5: Remove the flag MLX5_INTERFACE_STATE_SHUTDOWN
Date: Thu, 31 Aug 2017 01:21:04 +0300
Message-ID: <20170830222110.15737-6-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53252 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751341AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

MLX5_INTERFACE_STATE_SHUTDOWN is not used in the code.

Fixes: 5fc7197d3a25 ("net/mlx5: Add pci shutdown callback")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 --
 include/linux/mlx5/driver.h                    | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 4cdb414aa2d5..16885827367b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1563,8 +1563,6 @@ static void shutdown(struct pci_dev *pdev)
 	int err;
 
 	dev_info(&pdev->dev, "Shutdown was called\n");
-	/* Notify mlx5 clients that the kernel is being shut down */
-	set_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &dev->intf_state);
 	err = mlx5_try_fast_unload(dev);
 	if (err)
 		mlx5_unload_one(dev, priv, false);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 918f5e644506..205d82d4c468 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -674,7 +674,6 @@ enum mlx5_device_state {
 
 enum mlx5_interface_state {
 	MLX5_INTERFACE_STATE_UP = BIT(0),
-	MLX5_INTERFACE_STATE_SHUTDOWN = BIT(1),
 };
 
 enum mlx5_pci_status {
-- 
2.13.0
