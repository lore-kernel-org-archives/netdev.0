From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/4 v2] net: mvmdio: rename base register cookie from smireg
 to regs
Date: Thu, 14 Mar 2013 19:08:33 +0100
Message-ID: <1363284515-9865-3-git-send-email-florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
 <1363284515-9865-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Russell King <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 Rob Herring <rob.herring@calxeda.com>,
 Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
 Paul Mackerras <paulus@samba.org>, linux-arm-kernel@lists.infradead.org,
 Rob Landley <rob@landley.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linuxppc-dev@lists.ozlabs.org, Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1363284515-9865-1-git-send-email-florian@openwrt.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch renames the base register cookie in the mvmdio drive from
"smireg" to "regs" since a subsequent patch is going to use an ioremap()
cookie whose size is larger than a single register of 4 bytes. No
functionnal code change introduced.

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- added Thomas Acked-by tag

 drivers/net/ethernet/marvell/mvmdio.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 8a182f1..595deea 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -38,7 +38,7 @@
 
 struct orion_mdio_dev {
 	struct mutex lock;
-	void __iomem *smireg;
+	void __iomem *regs;
 };
 
 /* Wait for the SMI unit to be ready for another operation
@@ -51,7 +51,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 
 	count = 0;
 	while (1) {
-		val = readl(dev->smireg);
+		val = readl(dev->regs);
 		if (!(val & MVMDIO_SMI_BUSY))
 			break;
 
@@ -86,12 +86,12 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
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
 
@@ -128,7 +128,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_WRITE_OPERATION            |
 		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->smireg);
+	       dev->regs);
 
 	mutex_unlock(&dev->lock);
 
@@ -177,8 +177,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
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
