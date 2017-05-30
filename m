From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net/mlxfw: select CONFIG_XZ_DEC
Date: Tue, 30 May 2017 11:26:14 +0200
Message-ID: <20170530092628.1306028-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new mlxfw code fails to build without the xz library:

drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_xz_dec_run':
:(.text.mlxfw_mfa2_xz_dec_run+0x8): undefined reference to `xz_dec_run'
drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_file_component_get':
:(.text.mlxfw_mfa2_file_component_get+0x218): undefined reference to `xz_dec_init'
:(.text.mlxfw_mfa2_file_component_get+0x2c0): undefined reference to `xz_dec_end'

This adds a Kconfig 'select' statement for it, which is also what
the other user of that library has.

Fixes: 410ed13cae39 ("Add the mlxfw module for Mellanox firmware flash process")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxfw/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxfw/Kconfig b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
index 56b60ac7bc34..2b21af8a2b1d 100644
--- a/drivers/net/ethernet/mellanox/mlxfw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxfw/Kconfig
@@ -4,3 +4,4 @@
 
 config MLXFW
         tristate "mlxfw" if COMPILE_TEST
+	select XZ_DEC
-- 
2.9.0
