From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: mdio-gpio: support access that may sleep
Date: Wed, 22 Apr 2015 13:06:54 -0400
Message-ID: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some systems using mdio-gpio may use gpio on message based busses, which
require sleeping (e.g. gpio from an I2C I/O expander).

Since this driver does not use IRQ handler, it is safe to use the
_cansleep suffixed gpio accessors.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/phy/mdio-gpio.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 49ce7ec..c9cb486c 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -80,7 +80,8 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 		 * assume the pin serves as pull-up. If direction is
 		 * output, the default value is high.
 		 */
-		gpio_set_value(bitbang->mdo, 1 ^ bitbang->mdo_active_low);
+		gpio_set_value_cansleep(bitbang->mdo,
+					1 ^ bitbang->mdo_active_low);
 		return;
 	}
 
@@ -96,7 +97,8 @@ static int mdio_get(struct mdiobb_ctrl *ctrl)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	return gpio_get_value(bitbang->mdio) ^ bitbang->mdio_active_low;
+	return gpio_get_value_cansleep(bitbang->mdio) ^
+		bitbang->mdio_active_low;
 }
 
 static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
@@ -105,9 +107,11 @@ static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
 	if (bitbang->mdo)
-		gpio_set_value(bitbang->mdo, what ^ bitbang->mdo_active_low);
+		gpio_set_value_cansleep(bitbang->mdo,
+					what ^ bitbang->mdo_active_low);
 	else
-		gpio_set_value(bitbang->mdio, what ^ bitbang->mdio_active_low);
+		gpio_set_value_cansleep(bitbang->mdio,
+					what ^ bitbang->mdio_active_low);
 }
 
 static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
@@ -115,7 +119,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	gpio_set_value(bitbang->mdc, what ^ bitbang->mdc_active_low);
+	gpio_set_value_cansleep(bitbang->mdc, what ^ bitbang->mdc_active_low);
 }
 
 static struct mdiobb_ops mdio_gpio_ops = {
-- 
2.3.5
