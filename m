From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next] ethernet: qualcomm: use spi instead of spi_device
Date: Thu,  7 May 2015 09:17:48 +0530
Message-ID: <1430970468-4636-1-git-send-email-varkab@cdac.in>
Cc: Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34329 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbEGDsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 23:48:25 -0400
Received: by pdbqa5 with SMTP id qa5so28931277pdb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 20:48:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All spi based drivers have an instance of struct spi_device
as spi. This patch renames spi_device to spi to synchronize
with all the drivers.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/qualcomm/qca_spi.c |   46 +++++++++++++++----------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index f66641d..c6b7498 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -839,7 +839,7 @@ static const struct of_device_id qca_spi_of_match[] = {
 MODULE_DEVICE_TABLE(of, qca_spi_of_match);
 
 static int
-qca_spi_probe(struct spi_device *spi_device)
+qca_spi_probe(struct spi_device *spi)
 {
 	struct qcaspi *qca = NULL;
 	struct net_device *qcaspi_devs = NULL;
@@ -847,52 +847,52 @@ qca_spi_probe(struct spi_device *spi_device)
 	u16 signature;
 	const char *mac;
 
-	if (!spi_device->dev.of_node) {
-		dev_err(&spi_device->dev, "Missing device tree\n");
+	if (!spi->dev.of_node) {
+		dev_err(&spi->dev, "Missing device tree\n");
 		return -EINVAL;
 	}
 
-	legacy_mode = of_property_read_bool(spi_device->dev.of_node,
+	legacy_mode = of_property_read_bool(spi->dev.of_node,
 					    "qca,legacy-mode");
 
 	if (qcaspi_clkspeed == 0) {
-		if (spi_device->max_speed_hz)
-			qcaspi_clkspeed = spi_device->max_speed_hz;
+		if (spi->max_speed_hz)
+			qcaspi_clkspeed = spi->max_speed_hz;
 		else
 			qcaspi_clkspeed = QCASPI_CLK_SPEED;
 	}
 
 	if ((qcaspi_clkspeed < QCASPI_CLK_SPEED_MIN) ||
 	    (qcaspi_clkspeed > QCASPI_CLK_SPEED_MAX)) {
-		dev_info(&spi_device->dev, "Invalid clkspeed: %d\n",
+		dev_info(&spi->dev, "Invalid clkspeed: %d\n",
 			 qcaspi_clkspeed);
 		return -EINVAL;
 	}
 
 	if ((qcaspi_burst_len < QCASPI_BURST_LEN_MIN) ||
 	    (qcaspi_burst_len > QCASPI_BURST_LEN_MAX)) {
-		dev_info(&spi_device->dev, "Invalid burst len: %d\n",
+		dev_info(&spi->dev, "Invalid burst len: %d\n",
 			 qcaspi_burst_len);
 		return -EINVAL;
 	}
 
 	if ((qcaspi_pluggable < QCASPI_PLUGGABLE_MIN) ||
 	    (qcaspi_pluggable > QCASPI_PLUGGABLE_MAX)) {
-		dev_info(&spi_device->dev, "Invalid pluggable: %d\n",
+		dev_info(&spi->dev, "Invalid pluggable: %d\n",
 			 qcaspi_pluggable);
 		return -EINVAL;
 	}
 
-	dev_info(&spi_device->dev, "ver=%s, clkspeed=%d, burst_len=%d, pluggable=%d\n",
+	dev_info(&spi->dev, "ver=%s, clkspeed=%d, burst_len=%d, pluggable=%d\n",
 		 QCASPI_DRV_VERSION,
 		 qcaspi_clkspeed,
 		 qcaspi_burst_len,
 		 qcaspi_pluggable);
 
-	spi_device->mode = SPI_MODE_3;
-	spi_device->max_speed_hz = qcaspi_clkspeed;
-	if (spi_setup(spi_device) < 0) {
-		dev_err(&spi_device->dev, "Unable to setup SPI device\n");
+	spi->mode = SPI_MODE_3;
+	spi->max_speed_hz = qcaspi_clkspeed;
+	if (spi_setup(spi) < 0) {
+		dev_err(&spi->dev, "Unable to setup SPI device\n");
 		return -EFAULT;
 	}
 
@@ -905,21 +905,21 @@ qca_spi_probe(struct spi_device *spi_device)
 	qca = netdev_priv(qcaspi_devs);
 	if (!qca) {
 		free_netdev(qcaspi_devs);
-		dev_err(&spi_device->dev, "Fail to retrieve private structure\n");
+		dev_err(&spi->dev, "Fail to retrieve private structure\n");
 		return -ENOMEM;
 	}
 	qca->net_dev = qcaspi_devs;
-	qca->spi_dev = spi_device;
+	qca->spi_dev = spi;
 	qca->legacy_mode = legacy_mode;
 
-	mac = of_get_mac_address(spi_device->dev.of_node);
+	mac = of_get_mac_address(spi->dev.of_node);
 
 	if (mac)
 		ether_addr_copy(qca->net_dev->dev_addr, mac);
 
 	if (!is_valid_ether_addr(qca->net_dev->dev_addr)) {
 		eth_hw_addr_random(qca->net_dev);
-		dev_info(&spi_device->dev, "Using random MAC address: %pM\n",
+		dev_info(&spi->dev, "Using random MAC address: %pM\n",
 			 qca->net_dev->dev_addr);
 	}
 
@@ -930,7 +930,7 @@ qca_spi_probe(struct spi_device *spi_device)
 		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
 
 		if (signature != QCASPI_GOOD_SIGNATURE) {
-			dev_err(&spi_device->dev, "Invalid signature (0x%04X)\n",
+			dev_err(&spi->dev, "Invalid signature (0x%04X)\n",
 				signature);
 			free_netdev(qcaspi_devs);
 			return -EFAULT;
@@ -938,13 +938,13 @@ qca_spi_probe(struct spi_device *spi_device)
 	}
 
 	if (register_netdev(qcaspi_devs)) {
-		dev_info(&spi_device->dev, "Unable to register net device %s\n",
+		dev_info(&spi->dev, "Unable to register net device %s\n",
 			 qcaspi_devs->name);
 		free_netdev(qcaspi_devs);
 		return -EFAULT;
 	}
 
-	spi_set_drvdata(spi_device, qcaspi_devs);
+	spi_set_drvdata(spi, qcaspi_devs);
 
 	qcaspi_init_device_debugfs(qca);
 
@@ -952,9 +952,9 @@ qca_spi_probe(struct spi_device *spi_device)
 }
 
 static int
-qca_spi_remove(struct spi_device *spi_device)
+qca_spi_remove(struct spi_device *spi)
 {
-	struct net_device *qcaspi_devs = spi_get_drvdata(spi_device);
+	struct net_device *qcaspi_devs = spi_get_drvdata(spi);
 	struct qcaspi *qca = netdev_priv(qcaspi_devs);
 
 	qcaspi_remove_device_debugfs(qca);
-- 
1.7.9.5
