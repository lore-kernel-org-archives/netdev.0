From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/7] net: wireless: wl1251: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:36:25 +0900
Message-ID: <001001ce3291$0f8cde60$2ea69b20$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:60683 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304Ab3DFGg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:36:26 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT00DWIMCPJ9D0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:36:25 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/ti/wl1251/spi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 3b266d3..4c67c2f 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -257,7 +257,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	wl = hw->priv;
 
 	SET_IEEE80211_DEV(hw, &spi->dev);
-	dev_set_drvdata(&spi->dev, wl);
+	spi_set_drvdata(spi, wl);
 	wl->if_priv = spi;
 	wl->if_ops = &wl1251_spi_ops;
 
@@ -311,7 +311,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 
 static int wl1251_spi_remove(struct spi_device *spi)
 {
-	struct wl1251 *wl = dev_get_drvdata(&spi->dev);
+	struct wl1251 *wl = spi_get_drvdata(spi);
 
 	free_irq(wl->irq, wl);
 	wl1251_free_hw(wl);
-- 
1.7.2.5
