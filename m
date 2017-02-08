From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net] net: phy: Initialize mdio clock at probe function
Date: Wed,  8 Feb 2017 17:14:26 -0500
Message-ID: <1486592066-9097-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>

USB PHYs need the MDIO clock divisor enabled earlier to work.
Initialize mdio clock divisor in probe function. The ext bus
bit available in the same register will be used by mdio mux
to enable external mdio.

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Fixes: ddc24ae1 ("net: phy: Broadcom iProc MDIO bus driver")
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/phy/mdio-bcm-iproc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio-bcm-iproc.c b/drivers/net/phy/mdio-bcm-iproc.c
index c0b4e65..46fe1ae 100644
--- a/drivers/net/phy/mdio-bcm-iproc.c
+++ b/drivers/net/phy/mdio-bcm-iproc.c
@@ -81,8 +81,6 @@ static int iproc_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	if (rc)
 		return rc;
 
-	iproc_mdio_config_clk(priv->base);
-
 	/* Prepare the read operation */
 	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
 		(reg << MII_DATA_RA_SHIFT) |
@@ -112,8 +110,6 @@ static int iproc_mdio_write(struct mii_bus *bus, int phy_id,
 	if (rc)
 		return rc;
 
-	iproc_mdio_config_clk(priv->base);
-
 	/* Prepare the write operation */
 	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
 		(reg << MII_DATA_RA_SHIFT) |
@@ -163,6 +159,8 @@ static int iproc_mdio_probe(struct platform_device *pdev)
 	bus->read = iproc_mdio_read;
 	bus->write = iproc_mdio_write;
 
+	iproc_mdio_config_clk(priv->base);
+
 	rc = of_mdiobus_register(bus, pdev->dev.of_node);
 	if (rc) {
 		dev_err(&pdev->dev, "MDIO bus registration failed\n");
-- 
2.7.4
