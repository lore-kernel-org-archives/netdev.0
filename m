From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 6/7] can: mcp251x: define helper functions mcp251x_is_2510,
	mcp251x_is_2515
Date: Fri, 15 Oct 2010 12:49:21 +0200
Message-ID: <1287139762-23356-7-git-send-email-mkl@pengutronix.de>
References: <1287139762-23356-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287139762-23356-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mcp251x.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index f5e2edd..28281f9 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -252,6 +252,16 @@ struct mcp251x_priv {
 	int restart_tx;
 };
 
+#define MCP251X_IS(_model) \
+static inline int mcp251x_is_##_model(struct spi_device *spi) \
+{ \
+	struct mcp251x_platform_data *pdata = spi->dev.platform_data; \
+	return pdata->model == CAN_MCP251X_MCP##_model; \
+}
+
+MCP251X_IS(2510);
+MCP251X_IS(2515);
+
 static void mcp251x_clean(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
@@ -362,10 +372,9 @@ static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
 static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 				int len, int tx_buf_idx)
 {
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	if (pdata->model == CAN_MCP251X_MCP2510) {
+	if (mcp251x_is_2510(spi)) {
 		int i;
 
 		for (i = 1; i < TXBDAT_OFF + len; i++)
@@ -408,9 +417,8 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 				int buf_idx)
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
-	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 
-	if (pdata->model == CAN_MCP251X_MCP2510) {
+	if (mcp251x_is_2510(spi)) {
 		int i, len;
 
 		for (i = 1; i < RXBDAT_OFF; i++)
-- 
1.7.0.4
