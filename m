From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/5] IB/mlx4_ib: Adapt code to use caps.num_ports instead of a constant
Date: Wed, 19 Mar 2014 18:11:49 +0200
Message-ID: <1395245513-8139-2-git-send-email-ogerlitz@mellanox.com>
References: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com, matanb@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37107 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933939AbaCSQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 12:12:18 -0400
In-Reply-To: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Some code in the mlx4 IB driver stack assumed MLX4_MAX_PORTS ports.

Instead, we should only loop until the number of actual ports in i
the device, which is stored in dev->caps.num_ports.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 1d1750e..2ff428b 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1546,7 +1546,7 @@ static int mlx4_ib_addr_event(int event, struct net_device *event_netdev,
 	iboe = &ibdev->iboe;
 	spin_lock(&iboe->lock);
 
-	for (port = 1; port <= MLX4_MAX_PORTS; ++port)
+	for (port = 1; port <= ibdev->dev->caps.num_ports; ++port)
 		if ((netif_is_bond_master(real_dev) &&
 		     (real_dev == iboe->masters[port - 1])) ||
 		     (!netif_is_bond_master(real_dev) &&
@@ -1569,14 +1569,14 @@ static u8 mlx4_ib_get_dev_port(struct net_device *dev,
 
 	iboe = &ibdev->iboe;
 
-	for (port = 1; port <= MLX4_MAX_PORTS; ++port)
+	for (port = 1; port <= ibdev->dev->caps.num_ports; ++port)
 		if ((netif_is_bond_master(real_dev) &&
 		     (real_dev == iboe->masters[port - 1])) ||
 		     (!netif_is_bond_master(real_dev) &&
 		     (real_dev == iboe->netdevs[port - 1])))
 			break;
 
-	if ((port == 0) || (port > MLX4_MAX_PORTS))
+	if ((port == 0) || (port > ibdev->dev->caps.num_ports))
 		return 0;
 	else
 		return port;
@@ -1626,7 +1626,7 @@ static void mlx4_ib_get_dev_addr(struct net_device *dev,
 	union ib_gid gid;
 
 
-	if ((port == 0) || (port > MLX4_MAX_PORTS))
+	if ((port == 0) || (port > ibdev->dev->caps.num_ports))
 		return;
 
 	/* IPv4 gids */
-- 
1.7.1
