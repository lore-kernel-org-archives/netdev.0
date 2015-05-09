From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH] net: qca_spi: Fix possible race during probe
Date: Sat,  9 May 2015 07:58:09 +0000
Message-ID: <1431158289-27946-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org,
	Michael Heimpold <michael.heimpold@i2se.com>,
	Stefan Wahren <stefan.wahren@i2se.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:51748 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754AbbEIH7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Registering the netdev before setting the priv data is unsafe.
So fix this possible race by setting the priv data first.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Cc: <stable@vger.kernel.org> # v3.18+
Fixes: 291ab06e (net: qualcomm: new Ethernet over SPI driver for QCA7000)
---
 drivers/net/ethernet/qualcomm/qca_spi.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 4a42e96..946317a 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -913,6 +913,8 @@ qca_spi_probe(struct spi_device *spi_device)
 	qca->spi_dev = spi_device;
 	qca->legacy_mode = legacy_mode;
 
+	spi_set_drvdata(spi_device, qcaspi_devs);
+
 	mac = of_get_mac_address(spi_device->dev.of_node);
 
 	if (mac)
@@ -945,8 +947,6 @@ qca_spi_probe(struct spi_device *spi_device)
 		return -EFAULT;
 	}
 
-	spi_set_drvdata(spi_device, qcaspi_devs);
-
 	qcaspi_init_device_debugfs(qca);
 
 	return 0;
-- 
1.7.9.5
