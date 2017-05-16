From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] [net, 4.12] mlx5e: add CONFIG_INET dependency
Date: Tue, 16 May 2017 13:27:49 +0200
Message-ID: <20170516112807.4107417-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We now reference the arp_tbl, which requires IPv4 support to be
enabled in the kernel, otherwise we get a link error:

drivers/net/built-in.o: In function `mlx5e_tc_update_neigh_used_value':
(.text+0x16afec): undefined reference to `arp_tbl'
drivers/net/built-in.o: In function `mlx5e_rep_neigh_init':
en_rep.c:(.text+0x16c16d): undefined reference to `arp_tbl'
drivers/net/built-in.o: In function `mlx5e_rep_netevent_event':
en_rep.c:(.text+0x16cbb5): undefined reference to `arp_tbl'

This adds a Kconfig dependency for it.

Fixes: 232c001398ae ("net/mlx5e: Add support to neighbour update flow")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
Note: the mlxsw driver has referenced the same symbol for a while,
but had an implicit dependency on CONFIG_INET since it also depends
on SWITCHDEV.

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index fc52d742b7f7..27251a78075c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -13,7 +13,7 @@ config MLX5_CORE
 
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
-	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
+	depends on NETDEVICES && ETHERNET && INET && PCI && MLX5_CORE
 	depends on IPV6=y || IPV6=n || MLX5_CORE=m
 	imply PTP_1588_CLOCK
 	default n
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
