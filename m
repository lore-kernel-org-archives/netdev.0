From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/8] can: mcp251x: define helper functions mcp251x_is_2510, mcp251x_is_2515
Date: Mon, 18 Oct 2010 15:31:13 +0200
Message-ID: <1287408674-15412-8-git-send-email-mkl@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33914 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755620Ab0JRNbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 09:31:22 -0400
In-Reply-To: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/mcp251x.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 0386bed..7f8aa4c 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -258,6 +258,16 @@ struct mcp251x_priv {
 	int restart_tx;
 };
 
+#define MCP251X_IS(_model) \
+static inline int mcp251x_is_##_model(struct spi_device *spi) \
+{ \
+	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev); \
+	return priv->model == CAN_MCP251X_MCP##_model; \
+}
+
+MCP251X_IS(2510);
+MCP251X_IS(2515);
+
 static void mcp251x_clean(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
@@ -370,7 +380,7 @@ static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	if (priv->model == CAN_MCP251X_MCP2510) {
+	if (mcp251x_is_2510(spi)) {
 		int i;
 
 		for (i = 1; i < TXBDAT_OFF + len; i++)
@@ -414,7 +424,7 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	if (priv->model == CAN_MCP251X_MCP2510) {
+	if (mcp251x_is_2510(spi)) {
 		int i, len;
 
 		for (i = 1; i < RXBDAT_OFF; i++)
-- 
1.7.0.4

