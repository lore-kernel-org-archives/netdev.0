From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/7] net/mlx5: Build wq.o even if MLX5_CORE_EN is not selected
Date: Sun,  9 Jul 2017 15:49:15 +0300
Message-ID: <20170709124917.12852-6-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36252 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752176AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Both the ethernet and FPGA portions of MLX5 now require the wq functions,
and we get a link error when CONFIG_MLX5_CORE_EN is disabled:

drivers/net/ethernet/mellanox/mlx5/core/fpga/conn.o: In function `mlx5_fpga_conn_create_cq':
conn.c:(.text+0x10b3): undefined reference to `mlx5_cqwq_create'
conn.c:(.text+0x10c6): undefined reference to `mlx5_cqwq_get_size'
conn.c:(.text+0x12bc): undefined reference to `mlx5_cqwq_destroy'

Build wq.o even if MLX5_CORE_EN is not selected.

Fixes: 537a50574175 ("net/mlx5: FPGA, Add high-speed connection routines")
Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index ca367445f864..9d17e4e76d3a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -4,14 +4,14 @@ subdir-ccflags-y += -I$(src)
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
-		fs_counters.o rl.o lag.o dev.o lib/gid.o
+		fs_counters.o rl.o lag.o dev.o wq.o lib/gid.o
 
 mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
 
 mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o fpga/sdk.o \
 		fpga/ipsec.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += eswitch.o eswitch_offloads.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
 		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
-- 
2.11.0
