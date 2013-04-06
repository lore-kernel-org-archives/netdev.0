From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 6/7] net: wireless: p54spi: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:36:47 +0900
Message-ID: <001101ce3291$1d1846a0$5748d3e0$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:21852 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3DFGgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:36:49 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT00MHUMD7DE60@mailout1.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:36:48 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/p54/p54spi.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 4fd49a0..978e7eb 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -396,7 +396,7 @@ static int p54spi_rx(struct p54s_priv *priv)
 static irqreturn_t p54spi_interrupt(int irq, void *config)
 {
 	struct spi_device *spi = config;
-	struct p54s_priv *priv = dev_get_drvdata(&spi->dev);
+	struct p54s_priv *priv = spi_get_drvdata(spi);
 
 	ieee80211_queue_work(priv->hw, &priv->work);
 
@@ -609,7 +609,7 @@ static int p54spi_probe(struct spi_device *spi)
 
 	priv = hw->priv;
 	priv->hw = hw;
-	dev_set_drvdata(&spi->dev, priv);
+	spi_set_drvdata(spi, priv);
 	priv->spi = spi;
 
 	spi->bits_per_word = 16;
@@ -685,7 +685,7 @@ err_free:
 
 static int p54spi_remove(struct spi_device *spi)
 {
-	struct p54s_priv *priv = dev_get_drvdata(&spi->dev);
+	struct p54s_priv *priv = spi_get_drvdata(spi);
 
 	p54_unregister_common(priv->hw);
 
-- 
1.7.2.5
