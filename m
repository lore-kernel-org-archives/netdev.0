From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 4/6] net: phy: Initialize mdio clock at probe function
Date: Wed,  9 Nov 2016 04:33:12 -0500
Message-ID: <1478683994-12008-5-git-send-email-yendapally.reddy@broadcom.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36130 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753437AbcKIJdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 04:33:41 -0500
Received: by mail-pf0-f178.google.com with SMTP id 189so124657429pfz.3
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 01:33:41 -0800 (PST)
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
