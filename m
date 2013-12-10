From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/7] net: phy: spi_ks8995: remove unnecessary spi_set_drvdata()
Date: Tue, 10 Dec 2013 12:50:42 +0900
Message-ID: <000e01cef55a$ffca41b0$ff5ec510$%han@samsung.com>
References: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:10428 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab3LJDun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:50:43 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXK008DKO0JRF80@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 10 Dec 2013 12:50:43 +0900 (KST)
In-reply-to: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
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
