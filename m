From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 1/6] net/mlx5e: Add qos capability check
Date: Tue,  6 Sep 2016 19:04:07 +0300
Message-ID: <1473177852-10711-2-git-send-email-saeedm@mellanox.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51589 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934024AbcIFQE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:04:29 -0400
In-Reply-To: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Make sure firmware supports qos before exposing the dcb api.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 03586ee..3b05810 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3111,7 +3111,8 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
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
