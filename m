From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 2/3] net/mlx5e: Remove select queue ndo initialization
Date: Tue,  9 Feb 2016 14:57:43 +0200
Message-ID: <1455022664-15202-3-git-send-email-saeedm@mellanox.com>
References: <1455022664-15202-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34106 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754609AbcBIM6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 07:58:31 -0500
In-Reply-To: <1455022664-15202-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently mlx5e_select_queue is redundant since num_tc is always 1.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6a3e430..bca6e85 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2137,9 +2137,6 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (priv->params.num_tc > 1)
-		mlx5e_netdev_ops.ndo_select_queue = mlx5e_select_queue;
-
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		mlx5e_netdev_ops.ndo_set_vf_mac = mlx5e_set_vf_mac;
 		mlx5e_netdev_ops.ndo_set_vf_vlan = mlx5e_set_vf_vlan;
-- 
1.7.1
