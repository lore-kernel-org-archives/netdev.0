From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/4] net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue
Date: Sun,  1 May 2016 22:59:55 +0300
Message-ID: <1462132797-22853-3-git-send-email-saeedm@mellanox.com>
References: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:55775 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752211AbcEAUCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 16:02:10 -0400
In-Reply-To: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

When MLX5_EN=y MLX5_CORE=y and VXLAN=m there is a linker error for
vxlan_get_rx_port() due to the fact that VXLAN is a module. Change Kconfig
to select VXLAN when MLX5_CORE=y. When MLX5_CORE=m there is no dependency
on the value of VXLAN.

Fixes: b3f63c3d5e2c ('net/mlx5e: Add netdev support for VXLAN tunneling')
Signed-off-by: Matthew Finlay <matt@mellanox.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 1cf722e..559d11a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -14,6 +14,7 @@ config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
 	select PTP_1588_CLOCK
+	select VXLAN if MLX5_CORE=y
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
-- 
2.8.0
