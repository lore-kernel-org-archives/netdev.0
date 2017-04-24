From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next] net: dsa: LAN9303: add i2c dependency
Date: Mon, 24 Apr 2017 10:07:37 +0200
Message-ID: <20170424080737.24897-1-tobias.regnery@gmail.com>
Cc: Tobias Regnery <tobias.regnery@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jbe@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Kconfig symbol for the I2C mode of the LAN9303 driver selects
REGMAP_I2C. This symbol depends on I2C but the driver doesen't has a
dependency on I2C.

With CONFIG_I2C=n kconfig fails to select REGMAP_I2C and we get the
following warning:

warning: (NET_DSA_SMSC_LAN9303_I2C) selects REGMAP_I2C which has unmet direct dependencies (I2C)

This results in a build failure because the regmap-i2c functions aren't
available:

drivers/base/regmap/regmap-i2c.c: In function 'regmap_smbus_byte_reg_read':
drivers/base/regmap/regmap-i2c.c:29:8: error: implicit declaration of function 'i2c_smbus_read_byte_data' [-Werror=implicit-function-declaration]

drivers/base/regmap/regmap-i2c.c: In function 'regmap_smbus_byte_reg_write':
drivers/base/regmap/regmap-i2c.c:47:9: error: implicit declaration of function 'i2c_smbus_write_byte_data' [-Werror=implicit-function-declaration]
...

Fix this by adding a kconfig dependency on the I2C subsystem.

Fixes: be4e119f9914 ("net: dsa: LAN9303: add I2C managed mode support")
Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/dsa/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 131a5b1cbfc8..862ee22303c2 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -59,7 +59,7 @@ config NET_DSA_SMSC_LAN9303
 
 config NET_DSA_SMSC_LAN9303_I2C
 	tristate "SMSC/Microchip LAN9303 3-ports 10/100 ethernet switch in I2C managed mode"
-	depends on NET_DSA
+	depends on NET_DSA && I2C
 	select NET_DSA_SMSC_LAN9303
 	select REGMAP_I2C
 	---help---
-- 
2.11.0
