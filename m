From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/15] mlxfw: Make the module selectable
Date: Fri, 23 Jun 2017 17:26:15 +0300
Message-ID: <20170623142622.16565-9-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54057 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754080AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

There are upcoming NIC (mlx5) use-cases where people want to avoid
building the mlxfw module, allow for that. The mlxsw module is
untouched and keeps selecting mlxfw.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxfw/Kconfig | 8 +++++++-
 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h | 9 +++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxfw/Kconfig b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
index 2b21af8a2b1d..186ebe783f97 100644
--- a/drivers/net/ethernet/mellanox/mlxfw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
@@ -3,5 +3,11 @@
 #
 
 config MLXFW
-        tristate "mlxfw" if COMPILE_TEST
+	tristate "Mellanox Technologies firmware flash module"
+	---help---
+	  This driver supports Mellanox Technologies Firmware
+	  flashing common logic.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called mlxfw.
 	select XZ_DEC
diff --git a/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h b/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
index beea4ba83495..9ca85383aa35 100644
--- a/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
+++ b/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
@@ -96,7 +96,16 @@ struct mlxfw_dev {
 	u16 psid_size;
 };
 
+#if IS_ENABLED(CONFIG_MLXFW)
 int mlxfw_firmware_flash(struct mlxfw_dev *mlxfw_dev,
 			 const struct firmware *firmware);
+#else
+static inline
+int mlxfw_firmware_flash(struct mlxfw_dev *mlxfw_dev,
+			 const struct firmware *firmware)
+{
+	return -EOPNOTSUPP;
+}
+#endif
 
 #endif
-- 
2.11.0
