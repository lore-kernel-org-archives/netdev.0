From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/7] net: can: mcp251x: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:35:14 +0900
Message-ID: <000d01ce3290$e5762e10$b0628a30$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:60639 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525Ab3DFGfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:35:16 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT00GIHMAQRSD0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:35:15 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/mcp251x.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 2b620c8..3444e9e 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -269,7 +269,7 @@ struct mcp251x_priv {
 #define MCP251X_IS(_model) \
 static inline int mcp251x_is_##_model(struct spi_device *spi) \
 { \
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev); \
+	struct mcp251x_priv *priv = spi_get_drvdata(spi); \
 	return priv->model == CAN_MCP251X_MCP##_model; \
 }
 
@@ -305,7 +305,7 @@ static void mcp251x_clean(struct net_device *net)
  */
 static int mcp251x_spi_trans(struct spi_device *spi, int len)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	struct spi_transfer t = {
 		.tx_buf = priv->spi_tx_buf,
 		.rx_buf = priv->spi_rx_buf,
@@ -333,7 +333,7 @@ static int mcp251x_spi_trans(struct spi_device *spi, int len)
 
 static u8 mcp251x_read_reg(struct spi_device *spi, uint8_t reg)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	u8 val = 0;
 
 	priv->spi_tx_buf[0] = INSTRUCTION_READ;
@@ -348,7 +348,7 @@ static u8 mcp251x_read_reg(struct spi_device *spi, uint8_t reg)
 static void mcp251x_read_2regs(struct spi_device *spi, uint8_t reg,
 		uint8_t *v1, uint8_t *v2)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	priv->spi_tx_buf[0] = INSTRUCTION_READ;
 	priv->spi_tx_buf[1] = reg;
@@ -361,7 +361,7 @@ static void mcp251x_read_2regs(struct spi_device *spi, uint8_t reg,
 
 static void mcp251x_write_reg(struct spi_device *spi, u8 reg, uint8_t val)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	priv->spi_tx_buf[0] = INSTRUCTION_WRITE;
 	priv->spi_tx_buf[1] = reg;
@@ -373,7 +373,7 @@ static void mcp251x_write_reg(struct spi_device *spi, u8 reg, uint8_t val)
 static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
 			       u8 mask, uint8_t val)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	priv->spi_tx_buf[0] = INSTRUCTION_BIT_MODIFY;
 	priv->spi_tx_buf[1] = reg;
@@ -386,7 +386,7 @@ static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
 static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 				int len, int tx_buf_idx)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	if (mcp251x_is_2510(spi)) {
 		int i;
@@ -403,7 +403,7 @@ static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 static void mcp251x_hw_tx(struct spi_device *spi, struct can_frame *frame,
 			  int tx_buf_idx)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	u32 sid, eid, exide, rtr;
 	u8 buf[SPI_TRANSFER_BUF_LEN];
 
@@ -434,7 +434,7 @@ static void mcp251x_hw_tx(struct spi_device *spi, struct can_frame *frame,
 static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 				int buf_idx)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	if (mcp251x_is_2510(spi)) {
 		int i, len;
@@ -454,7 +454,7 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 
 static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	struct sk_buff *skb;
 	struct can_frame *frame;
 	u8 buf[SPI_TRANSFER_BUF_LEN];
@@ -550,7 +550,7 @@ static int mcp251x_do_set_mode(struct net_device *net, enum can_mode mode)
 
 static int mcp251x_set_normal_mode(struct spi_device *spi)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	unsigned long timeout;
 
 	/* Enable interrupts */
@@ -620,7 +620,7 @@ static int mcp251x_setup(struct net_device *net, struct mcp251x_priv *priv,
 
 static int mcp251x_hw_reset(struct spi_device *spi)
 {
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	int ret;
 	unsigned long timeout;
 
@@ -1020,7 +1020,7 @@ static int mcp251x_can_probe(struct spi_device *spi)
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
 	priv->model = spi_get_device_id(spi)->driver_data;
 	priv->net = net;
-	dev_set_drvdata(&spi->dev, priv);
+	spi_set_drvdata(spi, priv);
 
 	priv->spi = spi;
 	mutex_init(&priv->mcp_lock);
@@ -1118,7 +1118,7 @@ error_out:
 static int mcp251x_can_remove(struct spi_device *spi)
 {
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	struct net_device *net = priv->net;
 
 	unregister_candev(net);
@@ -1144,7 +1144,7 @@ static int mcp251x_can_suspend(struct device *dev)
 {
 	struct spi_device *spi = to_spi_device(dev);
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 	struct net_device *net = priv->net;
 
 	priv->force_quit = 1;
@@ -1176,7 +1176,7 @@ static int mcp251x_can_resume(struct device *dev)
 {
 	struct spi_device *spi = to_spi_device(dev);
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
+	struct mcp251x_priv *priv = spi_get_drvdata(spi);
 
 	if (priv->after_suspend & AFTER_SUSPEND_POWER) {
 		pdata->power_enable(1);
-- 
1.7.2.5
