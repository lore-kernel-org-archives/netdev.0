From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] net: phy: spi_ks8895: Don't leak references to SPI devices
Date: Wed, 20 Apr 2016 12:54:05 +0100
Message-ID: <1461153245-7992-1-git-send-email-broonie@kernel.org>
Cc: netdev@vger.kernel.org, Mark Brown <broonie@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:56704 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbcDTLyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 07:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ks8895 driver is using spi_dev_get() apparently just to take a copy
of the SPI device used to instantiate it but never calls spi_dev_put()
to free it.  Since the device is guaranteed to exist between probe() and
remove() there should be no need for the driver to take an extra
reference to it so fix the leak by just using a straight assignment.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/phy/spi_ks8995.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index b5d50d458728..93ffedfa2994 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -441,7 +441,7 @@ static int ks8995_probe(struct spi_device *spi)
 		return -ENOMEM;
 
 	mutex_init(&ks->lock);
-	ks->spi = spi_dev_get(spi);
+	ks->spi = spi;
 	ks->chip = &ks8995_chip[variant];
 
 	if (ks->spi->dev.of_node) {
-- 
2.8.0.rc3
