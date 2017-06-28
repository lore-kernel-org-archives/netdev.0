From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] [net-next] net/mlx5e: select CONFIG_MLXFW
Date: Wed, 28 Jun 2017 22:10:13 +0200
Message-ID: <20170628201032.3178691-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Nicolas Pitre <nicolas.pitre-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With the introduction of mlx5 firmware flash support, we get a link
error with CONFIG_MLXFW=m and CONFIG_MLX5_CORE=y:

drivers/net/ethernet/mellanox/mlx5/core/fw.o: In function `mlx5_firmware_flash':
fw.c:(.text+0x9d4): undefined reference to `mlxfw_firmware_flash'

We could have a more elaborate method to force MLX5 to be a loadable
module in this case, but the easiest fix seems to be to always enable
MLXFW as well, like we do for CONFIG_MLXSW_SPECTRUM, which is the other
user of mlxfw_firmware_flash.

Fixes: 3ffaabecd1a1 ("net/mlx5e: Support the flash device ethtool callback")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index cf1ef48bfd8d..09edee060b03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -6,6 +6,7 @@ config MLX5_CORE
 	tristate "Mellanox Technologies ConnectX-4 and Connect-IB core driver"
 	depends on MAY_USE_DEVLINK
 	depends on PCI
+	select MLXFW
 	default n
 	---help---
 	  Core driver for low level functionality of the ConnectX-4 and
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
