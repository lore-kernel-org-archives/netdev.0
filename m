From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] mellanox: Change en_print to return void
Date: Mon, 22 Sep 2014 10:40:22 -0700
Message-ID: <1411407622.2952.49.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No caller or macro uses the return value so make it void.

Signed-off-by: Joe Perches <joe@perches.com>
---
This change is associated to a desire to eventually
change printk to return void.

 drivers/net/ethernet/mellanox/mlx4/en_main.c | 17 +++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  4 ++--
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 3626fdf..2091ae88 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -78,27 +78,24 @@ MLX4_EN_PARM_INT(inline_thold, MAX_INLINE,
 #define MAX_PFC_TX     0xff
 #define MAX_PFC_RX     0xff
 
-int en_print(const char *level, const struct mlx4_en_priv *priv,
-	     const char *format, ...)
+void en_print(const char *level, const struct mlx4_en_priv *priv,
+	      const char *format, ...)
 {
 	va_list args;
 	struct va_format vaf;
-	int i;
 
 	va_start(args, format);
 
 	vaf.fmt = format;
 	vaf.va = &args;
 	if (priv->registered)
-		i = printk("%s%s: %s: %pV",
-			   level, DRV_NAME, priv->dev->name, &vaf);
+		printk("%s%s: %s: %pV",
+		       level, DRV_NAME, priv->dev->name, &vaf);
 	else
-		i = printk("%s%s: %s: Port %d: %pV",
-			   level, DRV_NAME, dev_name(&priv->mdev->pdev->dev),
-			   priv->port, &vaf);
+		printk("%s%s: %s: Port %d: %pV",
+		       level, DRV_NAME, dev_name(&priv->mdev->pdev->dev),
+		       priv->port, &vaf);
 	va_end(args);
-
-	return i;
 }
 
 void mlx4_en_update_loopback_state(struct net_device *dev,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3de41be..03e95f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -836,8 +836,8 @@ extern const struct ethtool_ops mlx4_en_ethtool_ops;
  */
 
 __printf(3, 4)
-int en_print(const char *level, const struct mlx4_en_priv *priv,
-	     const char *format, ...);
+void en_print(const char *level, const struct mlx4_en_priv *priv,
+	      const char *format, ...);
 
 #define en_dbg(mlevel, priv, format, ...)				\
 do {									\
