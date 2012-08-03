From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V1 3/3] net/mlx4_core: Remove port type restrictions
Date: Fri,  3 Aug 2012 13:38:38 +0300
Message-ID: <1343990318-10744-4-git-send-email-yevgenyp@mellanox.co.il>
References: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:60391 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753187Ab2HCKis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 06:38:48 -0400
In-Reply-To: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port1=Eth, Port2=IB restriction is no longer required.
Having RoCE, there will always rdma port initialized over ConnectX
physical port, no matter whether the link layer is IB or Ethernet.
So we always have dual port IB device.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c  |    3 ---
 drivers/net/ethernet/mellanox/mlx4/sense.c |   14 --------------
 2 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 48d0e90..827b72d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -157,9 +157,6 @@ int mlx4_check_port_params(struct mlx4_dev *dev,
 					 "on this HCA, aborting.\n");
 				return -EINVAL;
 			}
-			if (port_type[i] == MLX4_PORT_TYPE_ETH &&
-			    port_type[i + 1] == MLX4_PORT_TYPE_IB)
-				return -EINVAL;
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/sense.c b/drivers/net/ethernet/mellanox/mlx4/sense.c
index 8024982..34ee09b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/sense.c
+++ b/drivers/net/ethernet/mellanox/mlx4/sense.c
@@ -81,20 +81,6 @@ void mlx4_do_sense_ports(struct mlx4_dev *dev,
 	}
 
 	/*
-	 * Adjust port configuration:
-	 * If port 1 sensed nothing and port 2 is IB, set both as IB
-	 * If port 2 sensed nothing and port 1 is Eth, set both as Eth
-	 */
-	if (stype[0] == MLX4_PORT_TYPE_ETH) {
-		for (i = 1; i < dev->caps.num_ports; i++)
-			stype[i] = stype[i] ? stype[i] : MLX4_PORT_TYPE_ETH;
-	}
-	if (stype[dev->caps.num_ports - 1] == MLX4_PORT_TYPE_IB) {
-		for (i = 0; i < dev->caps.num_ports - 1; i++)
-			stype[i] = stype[i] ? stype[i] : MLX4_PORT_TYPE_IB;
-	}
-
-	/*
 	 * If sensed nothing, remain in current configuration.
 	 */
 	for (i = 0; i < dev->caps.num_ports; i++)
-- 
1.7.7
