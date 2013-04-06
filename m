From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/7] net: ieee802154: mrf24j40: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:34:18 +0900
Message-ID: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:21700 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757064Ab3DFGeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:34:21 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT009Q9M8XZD90@mailout1.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:34:19 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ieee802154/mrf24j40.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 0ca8f88..ca00351 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -648,7 +648,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	init_completion(&devrec->tx_complete);
 	INIT_WORK(&devrec->irqwork, mrf24j40_isrwork);
 	devrec->spi = spi;
-	dev_set_drvdata(&spi->dev, devrec);
+	spi_set_drvdata(spi, devrec);
 
 	/* Register with the 802154 subsystem */
 
@@ -720,7 +720,7 @@ err_devrec:
 
 static int mrf24j40_remove(struct spi_device *spi)
 {
-	struct mrf24j40 *devrec = dev_get_drvdata(&spi->dev);
+	struct mrf24j40 *devrec = spi_get_drvdata(spi);
 
 	dev_dbg(printdev(devrec), "remove\n");
 
@@ -732,7 +732,7 @@ static int mrf24j40_remove(struct spi_device *spi)
 	 * complete? */
 
 	/* Clean up the SPI stuff. */
-	dev_set_drvdata(&spi->dev, NULL);
+	spi_set_drvdata(spi, NULL);
 	kfree(devrec->buf);
 	kfree(devrec);
 	return 0;
-- 
1.7.2.5
