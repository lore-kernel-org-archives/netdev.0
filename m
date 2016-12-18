From: Andrey Smirnov <andrew.smirnov@gmail.com>
Subject: [PATCH] at86rf230: Allow slow GPIO pins for "rstn"
Date: Sun, 18 Dec 2016 15:25:33 -0800
Message-ID: <1482103533-13187-1-git-send-email-andrew.smirnov@gmail.com>
Cc: Andrey Smirnov <andrew.smirnov@gmail.com>,
        Alexander Aring <aar@pengutronix.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Chris Healy <cphealy@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver code never touches "rstn" signal in atomic context, so there's
no need to implicitly put such restriction on it by using gpio_set_value
to manipulate it. Replace gpio_set_value to gpio_set_value_cansleep to
fix that.

As a an example of where such restriction might be inconvenient,
consider a hardware design where "rstn" is connected to a pin of I2C/SPI
GPIO expander chip.

Cc: Chris Healy <cphealy@gmail.com>
Signed-off-by: Andrey Smirnov <andrew.smirnov@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 9f10da6..7700690 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1710,9 +1710,9 @@ static int at86rf230_probe(struct spi_device *spi)
 	/* Reset */
 	if (gpio_is_valid(rstn)) {
 		udelay(1);
-		gpio_set_value(rstn, 0);
+		gpio_set_value_cansleep(rstn, 0);
 		udelay(1);
-		gpio_set_value(rstn, 1);
+		gpio_set_value_cansleep(rstn, 1);
 		usleep_range(120, 240);
 	}
 
-- 
2.5.5
