From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH] net: phy: mdio-octeon: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 18:15:15 +0800
Message-ID: <1377080115-58636-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <david.daney@cavium.com>, <wfp5p@virginia.edu>,
	<gregkh@linuxfoundation.org>, <sachin.kamat@linaro.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>
To: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<rob.herring@calxeda.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_set_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/phy/mdio-octeon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index b51fa1f..7f18f80 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -222,7 +222,7 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 	bus->mii_bus->read = octeon_mdiobus_read;
 	bus->mii_bus->write = octeon_mdiobus_write;
 
-	dev_set_drvdata(&pdev->dev, bus);
+	platform_set_drvdata(pdev, bus);
 
 	err = of_mdiobus_register(bus->mii_bus, pdev->dev.of_node);
 	if (err)
-- 
1.7.1
