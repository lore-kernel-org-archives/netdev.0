From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: systemport: rename rx_csum_en to rx_chk_en
Date: Tue,  1 Jul 2014 21:08:39 -0700
Message-ID: <1404274120-5717-5-git-send-email-f.fainelli@gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:57525 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaGBEJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:12 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so4177921qgd.21
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:11 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This boolean tells us whether we are using the RXCHK hardware block,
so use a variable name that reflects that. RXCHK might be used in the
future to implement Wake-on-LAN using ARP or unicast packets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 10 +++++-----
 drivers/net/ethernet/broadcom/bcmsysport.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 9dabcfbfc23a..f00793e45330 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -124,9 +124,9 @@ static int bcm_sysport_set_rx_csum(struct net_device *dev,
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	u32 reg;
 
-	priv->rx_csum_en = !!(wanted & NETIF_F_RXCSUM);
+	priv->rx_chk_en = !!(wanted & NETIF_F_RXCSUM);
 	reg = rxchk_readl(priv, RXCHK_CONTROL);
-	if (priv->rx_csum_en)
+	if (priv->rx_chk_en)
 		reg |= RXCHK_EN;
 	else
 		reg &= ~RXCHK_EN;
@@ -134,7 +134,7 @@ static int bcm_sysport_set_rx_csum(struct net_device *dev,
 	/* If UniMAC forwards CRC, we need to skip over it to get
 	 * a valid CHK bit to be set in the per-packet status word
 	 */
-	if (priv->rx_csum_en && priv->crc_fwd)
+	if (priv->rx_chk_en && priv->crc_fwd)
 		reg |= RXCHK_SKIP_FCS;
 	else
 		reg &= ~RXCHK_SKIP_FCS;
@@ -1674,7 +1674,7 @@ static int bcm_sysport_suspend(struct device *d)
 	}
 
 	/* Disable RXCHK if enabled */
-	if (priv->rx_csum_en) {
+	if (priv->rx_chk_en) {
 		reg = rxchk_readl(priv, RXCHK_CONTROL);
 		reg &= ~RXCHK_EN;
 		rxchk_writel(priv, reg, RXCHK_CONTROL);
@@ -1750,7 +1750,7 @@ static int bcm_sysport_resume(struct device *d)
 	}
 
 	/* Enable rxhck */
-	if (priv->rx_csum_en) {
+	if (priv->rx_chk_en) {
 		reg = rxchk_readl(priv, RXCHK_CONTROL);
 		reg |= RXCHK_EN;
 		rxchk_writel(priv, reg, RXCHK_CONTROL);
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 281c08246037..20ea7162478f 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -664,7 +664,7 @@ struct bcm_sysport_priv {
 	int			old_duplex;
 
 	/* Misc fields */
-	unsigned int		rx_csum_en:1;
+	unsigned int		rx_chk_en:1;
 	unsigned int		tsb_en:1;
 	unsigned int		crc_fwd:1;
 	u16			rev;
-- 
1.9.1
