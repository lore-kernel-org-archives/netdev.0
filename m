From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/2] Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
Date: Sun,  8 May 2016 14:55:24 +0300
Message-ID: <1462708525-23545-2-git-send-email-saeedm@mellanox.com>
References: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38947 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750716AbcEHLz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 07:55:57 -0400
In-Reply-To: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

This reverts commit 69976fb1045850a742deb9790ea49cbc6f497531.

We cannot select VXLAN when IPv4 support is disabled, that just gives
us additional build errors, including:

warning: (MLX5_CORE_EN) selects VXLAN which has unmet direct dependencies (NETDEVICES && NET_CORE && INET)
In file included from ../drivers/net/vxlan.c:36:0:
include/net/udp_tunnel.h: In function 'udp_tunnel_handle_offloads':
include/net/udp_tunnel.h:112:9: error: implicit declaration of function 'iptunnel_handle_offloads' [-Werror=implicit-function-declaration]
  return iptunnel_handle_offloads(skb, type);
         ^~~~~~~~~~~~~~~~~~~~~~~~

I'm sending a proper fix for the original bug in a separate patch.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 559d11a..1cf722e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -14,7 +14,6 @@ config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
 	select PTP_1588_CLOCK
-	select VXLAN if MLX5_CORE=y
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
-- 
2.8.0
