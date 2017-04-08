From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: mt7530: Include gpio/consumer.h for GPIO functions
Date: Sat,  8 Apr 2017 08:52:02 -0700
Message-ID: <20170408155202.20145-1-f.fainelli@gmail.com>
Cc: sean.wang@mediatek.com, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes build errors seen with CONFIG_GPIOLIB disabled and warnings enabled:

drivers/net/dsa/mt7530.c: In function 'mt7530_setup':
drivers/net/dsa/mt7530.c:948:3: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]
   gpiod_set_value_cansleep(priv->reset, 0);
   ^~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mt7530.c: In function 'mt7530_probe':
drivers/net/dsa/mt7530.c:1068:17: error: implicit declaration of function 'devm_gpiod_get_optional' [-Werror=implicit-function-declaration]
   priv->reset = devm_gpiod_get_optional(&mdiodev->dev, "reset",
                 ^~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mt7530.c:1069:13: error: 'GPIOD_OUT_LOW' undeclared (first use in this function)
             GPIOD_OUT_LOW);
             ^~~~~~~~~~~~~
drivers/net/dsa/mt7530.c:1069:13:

Fixes: b8f126a8d543 ("net-next: dsa: add dsa support for Mediatek MT7530 switch")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mt7530.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index a4f3b0b8c28e..b070c167e70f 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -26,6 +26,7 @@
 #include <linux/regmap.h>
 #include <linux/regulator/consumer.h>
 #include <linux/reset.h>
+#include <linux/gpio/consumer.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
 
-- 
2.9.3
