From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: mcp251x: get regulators optionally
Date: Thu, 16 Jul 2015 10:33:55 +0200
Message-ID: <1437035635-18635-3-git-send-email-mkl@pengutronix.de>
References: <1437035635-18635-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Stefan Agner <stefan@agner.ch>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1437035635-18635-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Agner <stefan@agner.ch>

The regulators power and transceiver are optional. If those are not
present, the pointer (or error pointer) is correctly handled by the
driver, hence we can use devm_regulator_get_optional safely, which
avoids regulators getting created.

Signed-off-by: Stefan Agner <stefan@agner.ch>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/spi/mcp251x.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index 3b2f34e6ba9b..b7e83c212023 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -1086,8 +1086,8 @@ static int mcp251x_can_probe(struct spi_device *spi)
 	if (ret)
 		goto out_clk;
 
-	priv->power = devm_regulator_get(&spi->dev, "vdd");
-	priv->transceiver = devm_regulator_get(&spi->dev, "xceiver");
+	priv->power = devm_regulator_get_optional(&spi->dev, "vdd");
+	priv->transceiver = devm_regulator_get_optional(&spi->dev, "xceiver");
 	if ((PTR_ERR(priv->power) == -EPROBE_DEFER) ||
 	    (PTR_ERR(priv->transceiver) == -EPROBE_DEFER)) {
 		ret = -EPROBE_DEFER;
-- 
2.1.4

