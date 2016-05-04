From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/3] net/mlx5e: don't build RFS without ethernet
Date: Wed,  4 May 2016 14:32:24 +0200
Message-ID: <1462365155-3861405-1-git-send-email-arnd@arndb.de>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net,
	Matthew Finlay <matt@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:59553 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbcEDMcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 08:32:52 -0400
In-Reply-To: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFS acceleration support in mlx5 is enabled whenever CONFIG_RFS_ACCEL
is in use. However, this fails if a user turns off CONFIG_MLX5_CORE_EN,
because the rfs code now calls into the ethernet portion of the
driver:

ERROR: "mlx5e_destroy_flow_table" [drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko] undefined!

This patch adds another Kconfig symbol to control the compilation of
the RFS code, to ensure it is only built if both the ethernet support
and the core RFS support are enabled.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig  | 4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile | 2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index f5c3b9465d8d..5efba14a1453 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -38,3 +38,7 @@ config MLX5_CORE_EN_VXLAN
 	depends on MLX5_CORE_EN && VXLAN && !(MLX5_CORE=y && VXLAN=m)
 	---help---
 	  Say Y here if you want to use VXLAN offloads in the driver.
+
+config MLX5_CORE_EN_RFS
+	def_bool y
+	depends on MLX5_CORE_EN && RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 6b8da0b36acd..29118c1debb7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -11,4 +11,4 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN_VXLAN) += vxlan.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
-mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o
+mlx5_core-$(CONFIG_MLX5_CORE_EN_RFS) +=  en_arfs.o
-- 
2.7.0
