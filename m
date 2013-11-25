From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: ieee802154: remove unnecessary spi_set_drvdata()
Date: Mon, 25 Nov 2013 11:09:34 +0900
Message-ID: <001901cee983$62dc37b0$2894a710$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	'Alexander Smirnov' <alex.bluesman.smirnov@gmail.com>,
	'Dmitry Eremin-Solenikov' <dbaryshkov@gmail.com>,
	'Jingoo Han' <jg1.han@samsung.com>,
	'Sascha Herrmann' <sascha@ps.nvbi.de>,
	'Stefan Schmidt' <stefan@datenfreihafen.org>,
	'Alan Ott' <alan@signal11.us>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:13518 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab3KYCJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 21:09:37 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS00J4TRBZ46E0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 11:09:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ieee802154/at86rf230.c |    2 --
 drivers/net/ieee802154/mrf24j40.c  |    1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 2cbe1c2..ab31544 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -987,7 +987,6 @@ err_gpio_dir:
 err_slp_tr:
 	gpio_free(lp->rstn);
 err_rstn:
-	spi_set_drvdata(spi, NULL);
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
 	return rc;
@@ -1006,7 +1005,6 @@ static int at86rf230_remove(struct spi_device *spi)
 		gpio_free(lp->slp_tr);
 	gpio_free(lp->rstn);
 
-	spi_set_drvdata(spi, NULL);
 	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
 
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index c6e46d6..246befa 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -715,7 +715,6 @@ static int mrf24j40_remove(struct spi_device *spi)
 	 * complete? */
 
 	/* Clean up the SPI stuff. */
-	spi_set_drvdata(spi, NULL);
 	kfree(devrec->buf);
 	kfree(devrec);
 	return 0;
-- 
1.7.10.4
