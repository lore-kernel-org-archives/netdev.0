From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 1/3] net/mlx5e: Remove select queue ndo initialization
Date: Tue,  2 Feb 2016 17:26:19 +0200
Message-ID: <1454426781-7128-2-git-send-email-ogerlitz@mellanox.com>
References: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:58040 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932763AbcBBP1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 10:27:01 -0500
In-Reply-To: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Currently mlx5e_select_queue is redundant since num_tc is always 1.

We remove setting that as part of constifying the structures
used for the netdev ops.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ---
 1 file changed, 3 deletions(-)

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
2.3.7
