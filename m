From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 01/12] net/mlx5: File renaming towards ptp core implementation
Date: Sat, 14 Oct 2017 11:48:16 -0700
Message-ID: <20171014184827.18491-2-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Feras Daoud <ferasda-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eitan Rabin <rabin-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Feras Daoud <ferasda-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

en_clock.c renamed clock.c and moved to lib/ as first step
towards relocating code to core part of the driver to allow
sharing between Ethernet and Infiniband.

Signed-off-by: Feras Daoud <ferasda-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Eitan Rabin <rabin-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig                     | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile                    | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/{en_clock.c => lib/clock.c} | 0
 3 files changed, 3 insertions(+), 3 deletions(-)
 rename drivers/net/ethernet/mellanox/mlx5/core/{en_clock.c => lib/clock.c} (100%)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index fdaef00465d7..25deaa5a534c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -6,6 +6,7 @@ config MLX5_CORE
 	tristate "Mellanox Technologies ConnectX-4 and Connect-IB core driver"
 	depends on MAY_USE_DEVLINK
 	depends on PCI
+	imply PTP_1588_CLOCK
 	default n
 	---help---
 	  Core driver for low level functionality of the ConnectX-4 and
@@ -29,7 +30,6 @@ config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && INET && PCI && MLX5_CORE
 	depends on IPV6=y || IPV6=n || MLX5_CORE=m
-	imply PTP_1588_CLOCK
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 87a3099808f3..d9621b2152d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -4,7 +4,7 @@ subdir-ccflags-y += -I$(src)
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
-		fs_counters.o rl.o lag.o dev.o wq.o lib/gid.o \
+		fs_counters.o rl.o lag.o dev.o wq.o lib/gid.o lib/clock.o \
 		diag/fs_tracepoint.o
 
 mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
@@ -13,7 +13,7 @@ mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o fpga/sdk.o \
 		fpga/ipsec.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += en_main.o en_common.o en_fs.o en_ethtool.o \
-		en_tx.o en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
+		en_tx.o en_rx.o en_rx_am.o en_txrx.o vxlan.o \
 		en_arfs.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_MPFS) += lib/mpfs.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
rename to drivers/net/ethernet/mellanox/mlx5/core/lib/clock.c
-- 
2.14.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
