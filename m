From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/mlx4: Set proper build dependancy with vxlan
Date: Sun, 30 Mar 2014 14:28:25 +0300
Message-ID: <1396178905-3817-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54340 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752612AbaC3L2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Mar 2014 07:28:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that vxlan_get_rx_port() is present in the kernel build in a manner
consistent with mlx4. Otherwise, mlx4 can be made built-in where vxlan as a module
and the linking phase of the kernel build fails. Add CONFIG_MLX4_EN_VXLAN for that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig     |    7 +++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 ++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 1a6e188..1486ce9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -23,6 +23,13 @@ config MLX4_EN_DCB
 
 	  If unsure, set to Y
 
+config MLX4_EN_VXLAN
+	bool "VXLAN offloads Support"
+	default y
+	depends on MLX4_EN && VXLAN && !(MLX4_EN=y && VXLAN=m)
+	---help---
+	  Say Y here if you want to use VXLAN offloads in the driver.
+
 config MLX4_CORE
 	tristate
 	depends on PCI
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 82d7eb5..44fa7b0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1698,8 +1698,10 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
+#ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
 		vxlan_get_rx_port(dev);
+#endif
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
-- 
1.7.1
