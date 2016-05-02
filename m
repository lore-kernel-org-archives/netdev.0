From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/12] net/mlx5e: Fix aRFS compilation dependency
Date: Mon,  2 May 2016 19:43:33 +0300
Message-ID: <1462207424-4463-2-git-send-email-saeedm@mellanox.com>
References: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40170 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752309AbcEBQoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 12:44:32 -0400
In-Reply-To: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

en_arfs.o should be compiled only if both CONFIG_MLX5_CORE_EN
and CONFIG_RFS_ACCEL are enabled.
Add MLX5_CORE_EN_RFS Kconfig that depends on both of them.

Fixes: 1cabe6b0965e ('net/mlx5e: Create aRFS flow tables')
Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig  | 8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile | 2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 1cf722e..69095d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -31,3 +31,11 @@ config MLX5_CORE_EN_DCB
 	  This flag is depended on the kernel's DCB support.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_EN_RFS
+	bool "Accelerated RFS (aRFS) Support"
+	default y
+	depends on MLX5_CORE_EN && RFS_ACCEL
+	---help---
+	  Say Y here if you want to use accelerated RFS (aRFS) in the
+	  driver.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 679e18f..1840346 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -9,4 +9,4 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_txrx.o en_clock.o vxlan.o en_tc.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
-mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o
+mlx5_core-$(CONFIG_MLX5_CORE_EN_RFS) +=  en_arfs.o
-- 
2.8.0
