From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4 v3] net: mvmdio: rename base register cookie from smireg to regs
Date: Fri, 22 Mar 2013 14:39:26 +0100
Message-ID: <1363959568-16976-3-git-send-email-florian@openwrt.org>
References: <1363284515-9865-1-git-send-email-florian@openwrt.org>
 <1363959568-16976-1-git-send-email-florian@openwrt.org>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:46996 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933311Ab3CVNjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 09:39:39 -0400
In-Reply-To: <1363959568-16976-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames the base register cookie in the mvmdio drive from
"smireg" to "regs" since a subsequent patch is going to use an ioremap()
cookie whose size is larger than a single register of 4 bytes. No
functionnal code change introduced.

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v2:
- rebased against latest version

Changes since v1:
- added Thomas Acked-by tag

 drivers/net/ethernet/marvell/mvmdio.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index bbc5fde..3e2711d 100644
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
 
@@ -178,8 +178,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		bus->irq[i] = PHY_POLL;
 
 	dev = bus->priv;
-	dev->smireg = devm_ioremap(&pdev->dev, r->start, resource_size(r));
-	if (!dev->smireg) {
+	dev->regs = devm_ioremap(&pdev->dev, r->start, resource_size(r));
+	if (!dev->regs) {
 		dev_err(&pdev->dev, "Unable to remap SMI register\n");
 		kfree(bus->irq);
 		mdiobus_free(bus);
-- 
1.7.10.4
