From: Florian Fainelli <florian@openwrt.org>
Subject: [RFC PATCH 1/4] net: mvmdio: rename base register cookie from smireg to regs
Date: Fri, 25 Jan 2013 11:06:46 +0100
Message-ID: <1359108409-4378-2-git-send-email-florian@openwrt.org>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Cc: linux-arm-kernel@lists.infradead.org, ian.molton@codethink.co.uk,
	jason@lakedaemon.net, andrew@lunn.ch, arnd@arndb.de,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:40883 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213Ab3AYKJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 05:09:36 -0500
In-Reply-To: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames the base register cookie in the mvmdio drive from
"smireg" to "regs" since a subsequent patch is going to use an ioremap()
cookie whose size is larger than a single register of 4 bytes. No
functionnal code change introduced.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/marvell/mvmdio.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 74f1c15..e4a89b2 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -39,7 +39,7 @@
 
 struct orion_mdio_dev {
 	struct mutex lock;
-	void __iomem *smireg;
+	void __iomem *regs;
 };
 
 /* Wait for the SMI unit to be ready for another operation
@@ -52,7 +52,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 
 	count = 0;
 	while (1) {
-		val = readl(dev->smireg);
+		val = readl(dev->regs);
 		if (!(val & MVMDIO_SMI_BUSY))
 			break;
 
@@ -87,12 +87,12 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_READ_OPERATION),
-	       dev->smireg);
+	       dev->regs);
 
 	/* Wait for the value to become available */
 	count = 0;
 	while (1) {
-		val = readl(dev->smireg);
+		val = readl(dev->regs);
 		if (val & MVMDIO_SMI_READ_VALID)
 			break;
 
@@ -129,7 +129,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_WRITE_OPERATION            |
 		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->smireg);
+	       dev->regs);
 
 	mutex_unlock(&dev->lock);
 
@@ -173,8 +173,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		bus->irq[i] = PHY_POLL;
 
 	dev = bus->priv;
-	dev->smireg = of_iomap(pdev->dev.of_node, 0);
-	if (!dev->smireg) {
+	dev->regs = of_iomap(pdev->dev.of_node, 0);
+	if (!dev->regs) {
 		dev_err(&pdev->dev, "No SMI register address given in DT\n");
 		kfree(bus->irq);
 		mdiobus_free(bus);
@@ -186,7 +186,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	ret = of_mdiobus_register(bus, np);
 	if (ret < 0) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
-		iounmap(dev->smireg);
+		iounmap(dev->regs);
 		kfree(bus->irq);
 		mdiobus_free(bus);
 		return ret;
-- 
1.7.10.4
