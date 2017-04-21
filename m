From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net: dsa: LAN9303: add I2C dependency
Date: Fri, 21 Apr 2017 18:22:40 +0200
Message-ID: <20170421162259.3312997-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh@kernel.org>,
        Juergen Beisert <jbe@pengutronix.de>,
        Sean Wang <sean.wang@mediatek.com>,
        John Crispin <john@phrozen.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_I2C=m and NET_DSA_SMSC_LAN9303=y, we run into a link error:

drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_byte_reg_read':
regmap-i2c.c:(.text.regmap_smbus_byte_reg_read+0x18): undefined reference to `i2c_smbus_read_byte_data'
drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_byte_reg_write':
regmap-i2c.c:(.text.regmap_smbus_byte_reg_write+0x18): undefined reference to `i2c_smbus_write_byte_data'
drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_reg_read':
regmap-i2c.c:(.text.regmap_smbus_word_reg_read+0x18): undefined reference to `i2c_smbus_read_word_data'
drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_read_swapped':
regmap-i2c.c:(.text.regmap_smbus_word_read_swapped+0x18): undefined reference to `i2c_smbus_read_word_data'
drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_write_swapped':

This adds a Kconfig dependency to avoid the broken configuration.

Fixes: be4e119f9914 ("net: dsa: LAN9303: add I2C managed mode support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
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
2.9.0
