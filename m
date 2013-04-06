From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 7/7] net: phy: spi_ks8995: use spi_get_drvdata() and
 spi_set_drvdata()
Date: Sat, 06 Apr 2013 15:37:07 +0900
Message-ID: <001201ce3291$2909fc10$7b1df430$%han@samsung.com>
References: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:26951 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448Ab3DFGhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 02:37:14 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKT006MZMDK0CD0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Sat, 06 Apr 2013 15:37:08 +0900 (KST)
In-reply-to: <000c01ce3290$c44c0980$4ce41c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
spi_device instead of using dev_{get|set}_drvdata with &spi->dev, so we
can directly pass a struct spi_device.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/spi_ks8995.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 5c87eef..d11c93e 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -281,7 +281,7 @@ static int ks8995_probe(struct spi_device *spi)
 	mutex_init(&ks->lock);
 	ks->pdata = pdata;
 	ks->spi = spi_dev_get(spi);
-	dev_set_drvdata(&spi->dev, ks);
+	spi_set_drvdata(spi, ks);
 
 	spi->mode = SPI_MODE_0;
 	spi->bits_per_word = 8;
@@ -325,7 +325,7 @@ static int ks8995_probe(struct spi_device *spi)
 	return 0;
 
 err_drvdata:
-	dev_set_drvdata(&spi->dev, NULL);
+	spi_set_drvdata(spi, NULL);
 	kfree(ks);
 	return err;
 }
@@ -334,10 +334,10 @@ static int ks8995_remove(struct spi_device *spi)
 {
 	struct ks8995_data      *ks8995;
 
-	ks8995 = dev_get_drvdata(&spi->dev);
+	ks8995 = spi_get_drvdata(spi);
 	sysfs_remove_bin_file(&spi->dev.kobj, &ks8995_registers_attr);
 
-	dev_set_drvdata(&spi->dev, NULL);
+	spi_set_drvdata(spi, NULL);
 	kfree(ks8995);
 
 	return 0;
-- 
1.7.2.5
