From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx5e: Add qos capability check
Date: Sat, 26 Nov 2016 16:18:25 +0200
Message-ID: <1480169914-22347-2-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41839 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751724AbcKZOTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:32 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Make sure firmware supports qos before exposing the DCB API.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 19403d6..2b42112 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3549,7 +3549,8 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-		netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
+		if (MLX5_CAP_GEN(mdev, qos))
+			netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
 #endif
 	} else {
 		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
-- 
2.7.4
