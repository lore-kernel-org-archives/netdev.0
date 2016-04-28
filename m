From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/12] net/mlx5e: Call vxlan_get_rx_port() with rtnl lock
Date: Fri, 29 Apr 2016 01:36:31 +0300
Message-ID: <1461883002-8912-2-git-send-email-saeedm@mellanox.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33126 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750847AbcD1WiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:18 -0400
In-Reply-To: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Hold the rtnl lock when calling vxlan_get_rx_port().

Fixes: b7aade15485a ("vxlan: break dependency with netdev drivers")
Signed-off-by: Matthew Finlay <matt@mellanox.com>
Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8484ac4..8ffaf5c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2936,8 +2936,11 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_tc_cleanup;
 	}
 
-	if (mlx5e_vxlan_allowed(mdev))
+	if (mlx5e_vxlan_allowed(mdev)) {
+		rtnl_lock();
 		vxlan_get_rx_port(netdev);
+		rtnl_unlock();
+	}
 
 	mlx5e_enable_async_events(priv);
 	schedule_work(&priv->set_rx_mode_work);
-- 
1.7.1
