From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] net/mlx5: include wq.o in non-ethernet build for FPGA
Date: Fri, 30 Jun 2017 17:43:52 +0200
Message-ID: <20170630154412.3575760-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Ilan Tayari <ilant@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Boris Pismenny <borisp@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both the ethernet and FPGA portions of MLX5 now require the wq functions,
and we get a link error when CONFIG_MLX5_CORE_EN is disabled:

drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.o: In function `mlx5_fpga_conn_create_cq':
conn.c:(.text+0x10b3): undefined reference to `mlx5_cqwq_create'
conn.c:(.text+0x10c6): undefined reference to `mlx5_cqwq_get_size'
conn.c:(.text+0x12bc): undefined reference to `mlx5_cqwq_destroy'

This includes the library in the core driver also when only the fpga
support is enabled.

Fixes: 537a50574175 ("net/mlx5: FPGA, Add high-speed connection routines")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index ca367445f864..50fe9e3c5dc2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -9,7 +9,7 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
 
 mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o fpga/sdk.o \
-		fpga/ipsec.o
+		fpga/ipsec.o wq.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
-- 
2.9.0
