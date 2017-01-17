From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH v2 2/4] net: phy: Initialize mdio clock at probe function
Date: Tue, 17 Jan 2017 11:14:28 -0500
Message-ID: <1484669670-4201-3-git-send-email-yendapally.reddy@broadcom.com>
References: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize mdio clock divisor in probe function. The ext bus
bit available in the same register will be used by mdio mux
to enable external mdio.

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
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
2.1.0
