From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 1/3] Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
Date: Wed,  4 May 2016 14:26:08 +0200
Message-ID: <1462364774-3792510-2-git-send-email-arnd@arndb.de>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramonvsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462364774-3792510-1-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 559d11a443bc..1cf722eba607 100644
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
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
