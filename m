From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: phy: spi_ks8995: remove unnecessary spi_set_drvdata()
Date: Mon, 25 Nov 2013 11:06:21 +0900
Message-ID: <001801cee982$efd07740$cf7165c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:61255 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab3KYCGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 21:06:23 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS00IJGR6M7ND0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 11:06:22 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/spi_ks8995.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index f3bea13..98fb9f3 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -325,7 +325,6 @@ static int ks8995_probe(struct spi_device *spi)
 	return 0;
 
 err_drvdata:
-	spi_set_drvdata(spi, NULL);
 	kfree(ks);
 	return err;
 }
@@ -337,7 +336,6 @@ static int ks8995_remove(struct spi_device *spi)
 	ks8995 = spi_get_drvdata(spi);
 	sysfs_remove_bin_file(&spi->dev.kobj, &ks8995_registers_attr);
 
-	spi_set_drvdata(spi, NULL);
 	kfree(ks8995);
 
 	return 0;
-- 
1.7.10.4
