From: <jeroen.de_wachter.ext@nokia.com>
Subject: [PATCH 2/2] encx24j600: Fix some checkstyle warnings
Date: Mon, 12 Dec 2016 14:29:09 +0100
Message-ID: <1481549349-8199-2-git-send-email-jeroen.de_wachter.ext@nokia.com>
References: <1481549349-8199-1-git-send-email-jeroen.de_wachter.ext@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
        <netdev@vger.kernel.org>,
        Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>
To: David Miller <davem@davemloft.net>,
        Jon Ringle <jringle@gridpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fr-hpida-esg-02.alcatel-lucent.com ([135.245.210.21]:42076 "EHLO
        smtp-fr.alcatel-lucent.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752282AbcLLNlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:41:10 -0500
In-Reply-To: <1481549349-8199-1-git-send-email-jeroen.de_wachter.ext@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>

Signed-off-by: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>
---
 drivers/net/ethernet/microchip/encx24j600-regmap.c | 17 +++++++++++------
 drivers/net/ethernet/microchip/encx24j600.c        | 16 ++++++++++++++--
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600-regmap.c b/drivers/net/ethernet/microchip/encx24j600-regmap.c
index f3bb905..44bb04d 100644
--- a/drivers/net/ethernet/microchip/encx24j600-regmap.c
+++ b/drivers/net/ethernet/microchip/encx24j600-regmap.c
@@ -26,11 +26,11 @@ static inline bool is_bits_set(int value, int mask)
 }
 
 static int encx24j600_switch_bank(struct encx24j600_context *ctx,
-					 int bank)
+				  int bank)
 {
 	int ret = 0;
-
 	int bank_opcode = BANK_SELECT(bank);
+
 	ret = spi_write(ctx->spi, &bank_opcode, 1);
 	if (ret == 0)
 		ctx->bank = bank;
@@ -39,7 +39,7 @@ static int encx24j600_switch_bank(struct encx24j600_context *ctx,
 }
 
 static int encx24j600_cmdn(struct encx24j600_context *ctx, u8 opcode,
-			    const void *buf, size_t len)
+			   const void *buf, size_t len)
 {
 	struct spi_message m;
 	struct spi_transfer t[2] = { { .tx_buf = &opcode, .len = 1, },
@@ -54,12 +54,14 @@ static int encx24j600_cmdn(struct encx24j600_context *ctx, u8 opcode,
 static void regmap_lock_mutex(void *context)
 {
 	struct encx24j600_context *ctx = context;
+
 	mutex_lock(&ctx->mutex);
 }
 
 static void regmap_unlock_mutex(void *context)
 {
 	struct encx24j600_context *ctx = context;
+
 	mutex_unlock(&ctx->mutex);
 }
 
@@ -128,6 +130,7 @@ static int regmap_encx24j600_sfr_update(struct encx24j600_context *ctx,
 
 	if (reg < 0x80) {
 		int ret = 0;
+
 		cmd = banked_code | banked_reg;
 		if ((banked_reg < 0x16) && (ctx->bank != bank))
 			ret = encx24j600_switch_bank(ctx, bank);
@@ -174,6 +177,7 @@ static int regmap_encx24j600_sfr_write(void *context, u8 reg, u8 *val,
 				       size_t len)
 {
 	struct encx24j600_context *ctx = context;
+
 	return regmap_encx24j600_sfr_update(ctx, reg, val, len, WCRU, WCRCODE);
 }
 
@@ -228,9 +232,9 @@ int regmap_encx24j600_spi_write(void *context, u8 reg, const u8 *data,
 
 	if (reg < 0xc0)
 		return encx24j600_cmdn(ctx, reg, data, count);
-	else
-		/* SPI 1-byte command. Ignore data */
-		return spi_write(ctx->spi, &reg, 1);
+
+	/* SPI 1-byte command. Ignore data */
+	return spi_write(ctx->spi, &reg, 1);
 }
 EXPORT_SYMBOL_GPL(regmap_encx24j600_spi_write);
 
@@ -495,6 +499,7 @@ static bool encx24j600_phymap_volatile(struct device *dev, unsigned int reg)
 	.writeable_reg = encx24j600_phymap_writeable,
 	.volatile_reg = encx24j600_phymap_volatile,
 };
+
 static struct regmap_bus phymap_encx24j600 = {
 	.reg_write = regmap_encx24j600_phy_reg_write,
 	.reg_read = regmap_encx24j600_phy_reg_read,
diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 5251aa3..fbce616 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -30,7 +30,7 @@
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 static int debug = -1;
-module_param(debug, int, 0);
+module_param(debug, int, 0000);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /* SRAM memory layout:
@@ -105,6 +105,7 @@ static u16 encx24j600_read_reg(struct encx24j600_priv *priv, u8 reg)
 	struct net_device *dev = priv->ndev;
 	unsigned int val = 0;
 	int ret = regmap_read(priv->ctx.regmap, reg, &val);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d reading reg %02x\n",
 			  __func__, ret, reg);
@@ -115,6 +116,7 @@ static void encx24j600_write_reg(struct encx24j600_priv *priv, u8 reg, u16 val)
 {
 	struct net_device *dev = priv->ndev;
 	int ret = regmap_write(priv->ctx.regmap, reg, val);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d writing reg %02x=%04x\n",
 			  __func__, ret, reg, val);
@@ -125,6 +127,7 @@ static void encx24j600_update_reg(struct encx24j600_priv *priv, u8 reg,
 {
 	struct net_device *dev = priv->ndev;
 	int ret = regmap_update_bits(priv->ctx.regmap, reg, mask, val);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d updating reg %02x=%04x~%04x\n",
 			  __func__, ret, reg, val, mask);
@@ -135,6 +138,7 @@ static u16 encx24j600_read_phy(struct encx24j600_priv *priv, u8 reg)
 	struct net_device *dev = priv->ndev;
 	unsigned int val = 0;
 	int ret = regmap_read(priv->ctx.phymap, reg, &val);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d reading %02x\n",
 			  __func__, ret, reg);
@@ -145,6 +149,7 @@ static void encx24j600_write_phy(struct encx24j600_priv *priv, u8 reg, u16 val)
 {
 	struct net_device *dev = priv->ndev;
 	int ret = regmap_write(priv->ctx.phymap, reg, val);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d writing reg %02x=%04x\n",
 			  __func__, ret, reg, val);
@@ -164,6 +169,7 @@ static void encx24j600_cmd(struct encx24j600_priv *priv, u8 cmd)
 {
 	struct net_device *dev = priv->ndev;
 	int ret = regmap_write(priv->ctx.regmap, cmd, 0);
+
 	if (unlikely(ret))
 		netif_err(priv, drv, dev, "%s: error %d with cmd %02x\n",
 			  __func__, ret, cmd);
@@ -173,6 +179,7 @@ static int encx24j600_raw_read(struct encx24j600_priv *priv, u8 reg, u8 *data,
 			       size_t count)
 {
 	int ret;
+
 	mutex_lock(&priv->ctx.mutex);
 	ret = regmap_encx24j600_spi_read(&priv->ctx, reg, data, count);
 	mutex_unlock(&priv->ctx.mutex);
@@ -184,6 +191,7 @@ static int encx24j600_raw_write(struct encx24j600_priv *priv, u8 reg,
 				const u8 *data, size_t count)
 {
 	int ret;
+
 	mutex_lock(&priv->ctx.mutex);
 	ret = regmap_encx24j600_spi_write(&priv->ctx, reg, data, count);
 	mutex_unlock(&priv->ctx.mutex);
@@ -194,6 +202,7 @@ static int encx24j600_raw_write(struct encx24j600_priv *priv, u8 reg,
 static void encx24j600_update_phcon1(struct encx24j600_priv *priv)
 {
 	u16 phcon1 = encx24j600_read_phy(priv, PHCON1);
+
 	if (priv->autoneg == AUTONEG_ENABLE) {
 		phcon1 |= ANEN | RENEG;
 	} else {
@@ -328,6 +337,7 @@ static int encx24j600_receive_packet(struct encx24j600_priv *priv,
 {
 	struct net_device *dev = priv->ndev;
 	struct sk_buff *skb = netdev_alloc_skb(dev, rsv->len + NET_IP_ALIGN);
+
 	if (!skb) {
 		pr_err_ratelimited("RX: OOM: packet dropped\n");
 		dev->stats.rx_dropped++;
@@ -828,6 +838,7 @@ static void encx24j600_set_multicast_list(struct net_device *dev)
 static void encx24j600_hw_tx(struct encx24j600_priv *priv)
 {
 	struct net_device *dev = priv->ndev;
+
 	netif_info(priv, tx_queued, dev, "TX Packet Len:%d\n",
 		   priv->tx_skb->len);
 
@@ -895,7 +906,6 @@ static void encx24j600_tx_timeout(struct net_device *dev)
 
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
-	return;
 }
 
 static int encx24j600_get_regs_len(struct net_device *dev)
@@ -958,12 +968,14 @@ static int encx24j600_set_settings(struct net_device *dev,
 static u32 encx24j600_get_msglevel(struct net_device *dev)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
+
 	return priv->msg_enable;
 }
 
 static void encx24j600_set_msglevel(struct net_device *dev, u32 val)
 {
 	struct encx24j600_priv *priv = netdev_priv(dev);
+
 	priv->msg_enable = val;
 }
 
-- 
1.8.3.1
