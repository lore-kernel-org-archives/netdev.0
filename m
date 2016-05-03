From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 01/12] net/mlx5e: Fix aRFS compilation dependency
Date: Tue,  3 May 2016 17:13:53 +0300
Message-ID: <1462284844-16926-2-git-send-email-saeedm@mellanox.com>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48718 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755316AbcECOO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:14:58 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

en_arfs.o should be compiled only if both CONFIG_MLX5_CORE_EN
and CONFIG_RFS_ACCEL are enabled. en_arfs calls to rps_may_expire_flow
which is compiled only if CONFIG_RFS_ACCEL is defined.

Move en_arfs.o compilation dependency to be under CONFIG_MLX5_CORE_EN
and wrap the en_arfs.c content with ifdef of CONFIG_RFS_ACCEL.

Fixes: 1cabe6b0965e ('net/mlx5e: Create aRFS flow tables')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  | 3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c | 3 +++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 679e18f..b531d4f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,7 +6,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o vxlan.o en_tc.o
+		en_txrx.o en_clock.o vxlan.o en_tc.o en_arfs.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
-mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index b4ae0fe..3515e78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -30,6 +30,8 @@
  * SOFTWARE.
  */
 
+#ifdef CONFIG_RFS_ACCEL
+
 #include <linux/hash.h>
 #include <linux/mlx5/fs.h>
 #include <linux/ip.h>
@@ -747,3 +749,4 @@ int mlx5e_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	spin_unlock_bh(&arfs->arfs_lock);
 	return arfs_rule->filter_id;
 }
+#endif
-- 
2.8.0
