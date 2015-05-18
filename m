From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH 2/2] can: mcp251x: get regulators optionally
Date: Mon, 18 May 2015 18:33:28 +0200
Message-ID: <1431966808-26213-2-git-send-email-stefan@agner.ch>
References: <1431966808-26213-1-git-send-email-stefan@agner.ch>
Cc: chripell@fsfe.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefan@agner.ch
To: wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1431966808-26213-1-git-send-email-stefan@agner.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The regulators power and transceiver are optional. If those are not
present, the pointer (or error pointer) is correctly handled by the
driver, hence we can use devm_regulator_get_optional safely, which
avoids regulators getting created.

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 drivers/net/can/spi/mcp251x.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
index 34c625e..117e78f 100644
--- a/drivers/net/can/spi/mcp251x.c
+++ b/drivers/net/can/spi/mcp251x.c
@@ -1085,8 +1085,8 @@ static int mcp251x_can_probe(struct spi_device *spi)
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
2.4.1

