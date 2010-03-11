From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 31/37] drivers/of: use .of_node instead of .archdata.of_node
	in struct device
Date: Thu, 11 Mar 2010 11:06:39 -0700
Message-ID: <20100311180638.4824.71650.stgit__7934.74164461276$1268331061$gmane$org@angua>
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
	with ESMTP id S933807Ab0CKSGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:06:42 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.archdata.node is being removed from Microblaze, SPARC and PowerPC.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/of_i2c.c  |    1 -
 drivers/of/of_mdio.c |    1 -
 drivers/of/of_spi.c  |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/of/of_i2c.c b/drivers/of/of_i2c.c
index 43f803e..ab6522c 100644
--- a/drivers/of/of_i2c.c
+++ b/drivers/of/of_i2c.c
@@ -42,7 +42,6 @@ void of_register_i2c_devices(struct i2c_adapter *adap,
 
 		info.addr = be32_to_cpup(addr);
 
-		dev_archdata_set_node(&dev_ad, node); /* temporary */
 		info.of_node = node;
 		info.archdata = &dev_ad;
 
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 64e08d7..794fbc2 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -79,7 +79,6 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 		/* Associate the OF node with the device structure so it
 		 * can be looked up later */
 		of_node_get(child);
-		dev_archdata_set_node(&phy->dev.archdata, child); /* temp */
 		phy->dev.of_node = child;
 
 		/* All data is now stored in the phy struct; register it */
diff --git a/drivers/of/of_spi.c b/drivers/of/of_spi.c
index 433d76d..5fed7e3 100644
--- a/drivers/of/of_spi.c
+++ b/drivers/of/of_spi.c
@@ -80,7 +80,6 @@ void of_register_spi_devices(struct spi_master *master, struct device_node *np)
 		/* Store a pointer to the node in the device structure */
 		of_node_get(nc);
 		spi->dev.of_node = nc;
-		spi->dev.archdata.of_node = nc; /* temporary */
 
 		/* Register the new device */
 		request_module(spi->modalias);

