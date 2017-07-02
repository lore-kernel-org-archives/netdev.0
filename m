From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/mlxfw: Properly handle dependancy with non-loadable mlx5
Date: Sun,  2 Jul 2017 18:57:28 +0300
Message-ID: <1499011048-24941-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        mlxsw@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57842 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751635AbdGBP5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 11:57:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If mlx5 is set to be built-in and mlxfw as a module, we
get a link error:

drivers/built-in.o: In function `mlx5_firmware_flash':
(.text+0x5aed72): undefined reference to `mlxfw_firmware_flash'

Since we don't want to mandate selecting mlxfw for mlx5 users, we
use the IS_REACHABLE macro to make sure that a stub is exposed
to the caller.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Jakub Kicinski <kubakici@wp.pl>
Reported-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h b/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
index 9ca8538..7a712b6 100644
--- a/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
+++ b/drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
@@ -96,7 +96,7 @@ struct mlxfw_dev {
 	u16 psid_size;
 };
 
-#if IS_ENABLED(CONFIG_MLXFW)
+#if IS_REACHABLE(CONFIG_MLXFW)
 int mlxfw_firmware_flash(struct mlxfw_dev *mlxfw_dev,
 			 const struct firmware *firmware);
 #else
-- 
2.3.7
