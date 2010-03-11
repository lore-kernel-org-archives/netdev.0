From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 14/37] drivers/spi: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:05:05 -0700
Message-ID: <20100311180504.4824.59817.stgit__15040.0971448564$1268331448$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34774 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933643Ab0CKSFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:05:22 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/spi/mpc52xx_psc_spi.c |   11 ++++++-----
 drivers/spi/mpc52xx_spi.c     |   14 +++++++-------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/spi/mpc52xx_psc_spi.c b/drivers/spi/mpc52xx_psc_spi.c
index 0474786..f12cfd9 100644
--- a/drivers/spi/mpc52xx_psc_spi.c
+++ b/drivers/spi/mpc52xx_psc_spi.c
@@ -471,18 +471,18 @@ static int __init mpc52xx_psc_spi_of_probe(struct of_device *op,
 	s16 id = -1;
 	int rc;
 
-	regaddr_p = of_get_address(op->node, 0, &size64, NULL);
+	regaddr_p = of_get_address(op->dev.of_node, 0, &size64, NULL);
 	if (!regaddr_p) {
 		dev_err(&op->dev, "Invalid PSC address\n");
 		return -EINVAL;
 	}
-	regaddr64 = of_translate_address(op->node, regaddr_p);
+	regaddr64 = of_translate_address(op->dev.of_node, regaddr_p);
 
 	/* get PSC id (1..6, used by port_config) */
 	if (op->dev.platform_data == NULL) {
 		const u32 *psc_nump;
 
-		psc_nump = of_get_property(op->node, "cell-index", NULL);
+		psc_nump = of_get_property(op->dev.of_node, "cell-index", NULL);
 		if (!psc_nump || *psc_nump > 5) {
 			dev_err(&op->dev, "Invalid cell-index property\n");
 			return -EINVAL;
@@ -491,9 +491,10 @@ static int __init mpc52xx_psc_spi_of_probe(struct of_device *op,
 	}
 
 	rc = mpc52xx_psc_spi_do_probe(&op->dev, (u32)regaddr64, (u32)size64,
-					irq_of_parse_and_map(op->node, 0), id);
+				irq_of_parse_and_map(op->dev.of_node, 0), id);
 	if (rc == 0)
-		of_register_spi_devices(dev_get_drvdata(&op->dev), op->node);
+		of_register_spi_devices(dev_get_drvdata(&op->dev),
+					op->dev.of_node);
 
 	return rc;
 }
diff --git a/drivers/spi/mpc52xx_spi.c b/drivers/spi/mpc52xx_spi.c
index 6eab465..907c39a 100644
--- a/drivers/spi/mpc52xx_spi.c
+++ b/drivers/spi/mpc52xx_spi.c
@@ -402,7 +402,7 @@ static int __devinit mpc52xx_spi_probe(struct of_device *op,
 
 	/* MMIO registers */
 	dev_dbg(&op->dev, "probing mpc5200 SPI device\n");
-	regs = of_iomap(op->node, 0);
+	regs = of_iomap(op->dev.of_node, 0);
 	if (!regs)
 		return -ENODEV;
 
@@ -444,11 +444,11 @@ static int __devinit mpc52xx_spi_probe(struct of_device *op,
 	ms = spi_master_get_devdata(master);
 	ms->master = master;
 	ms->regs = regs;
-	ms->irq0 = irq_of_parse_and_map(op->node, 0);
-	ms->irq1 = irq_of_parse_and_map(op->node, 1);
+	ms->irq0 = irq_of_parse_and_map(op->dev.of_node, 0);
+	ms->irq1 = irq_of_parse_and_map(op->dev.of_node, 1);
 	ms->state = mpc52xx_spi_fsmstate_idle;
-	ms->ipb_freq = mpc5xxx_get_bus_frequency(op->node);
-	ms->gpio_cs_count = of_gpio_count(op->node);
+	ms->ipb_freq = mpc5xxx_get_bus_frequency(op->dev.of_node);
+	ms->gpio_cs_count = of_gpio_count(op->dev.of_node);
 	if (ms->gpio_cs_count > 0) {
 		master->num_chipselect = ms->gpio_cs_count;
 		ms->gpio_cs = kmalloc(ms->gpio_cs_count * sizeof(unsigned int),
@@ -459,7 +459,7 @@ static int __devinit mpc52xx_spi_probe(struct of_device *op,
 		}
 
 		for (i = 0; i < ms->gpio_cs_count; i++) {
-			gpio_cs = of_get_gpio(op->node, i);
+			gpio_cs = of_get_gpio(op->dev.of_node, i);
 			if (gpio_cs < 0) {
 				dev_err(&op->dev,
 					"could not parse the gpio field "
@@ -511,7 +511,7 @@ static int __devinit mpc52xx_spi_probe(struct of_device *op,
 	if (rc)
 		goto err_register;
 
-	of_register_spi_devices(master, op->node);
+	of_register_spi_devices(master, op->dev.of_node);
 	dev_info(&ms->master->dev, "registered MPC5200 SPI bus\n");
 
 	return rc;

