From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] phylib: simplify NULL checks
Date: Fri, 28 Aug 2015 21:35:14 +0300
Message-ID: <1486594.t6eW57X3a7@wasted.cogentembedded.com>
References: <2163825.63u61975nF@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2163825.63u61975nF@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix scripts/checkpatch.pl's messages like:

CHECK: Comparison to NULL could be written "!phydrv->read_mmd_indirect"

BTW, it doesn't detect the reversed comparisons (which I've fixed as well).

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/phy.c        |    4 ++--
 drivers/net/phy/phy_device.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -1040,7 +1040,7 @@ int phy_read_mmd_indirect(struct phy_dev
 	struct phy_driver *phydrv = phydev->drv;
 	int value = -1;
 
-	if (phydrv->read_mmd_indirect == NULL) {
+	if (!phydrv->read_mmd_indirect) {
 		struct mii_bus *bus = phydev->bus;
 
 		mutex_lock(&bus->mdio_lock);
@@ -1077,7 +1077,7 @@ void phy_write_mmd_indirect(struct phy_d
 {
 	struct phy_driver *phydrv = phydev->drv;
 
-	if (phydrv->write_mmd_indirect == NULL) {
+	if (!phydrv->write_mmd_indirect) {
 		struct mii_bus *bus = phydev->bus;
 
 		mutex_lock(&bus->mdio_lock);
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -156,7 +156,7 @@ struct phy_device *phy_device_create(str
 
 	/* We allocate the device, and initialize the default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
-	if (NULL == dev)
+	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
 	dev->dev.release = phy_device_release;
@@ -178,7 +178,7 @@ struct phy_device *phy_device_create(str
 	dev->bus = bus;
 	dev->dev.parent = &bus->dev;
 	dev->dev.bus = &mdio_bus_type;
-	dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
+	dev->irq = bus->irq ? bus->irq[addr] : PHY_POLL;
 	dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
 
 	dev->state = PHY_DOWN;
@@ -589,7 +589,7 @@ int phy_attach_direct(struct net_device
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver.
 	 */
-	if (NULL == d->driver) {
+	if (!d->driver) {
 		if (phydev->is_c45)
 			d->driver = &genphy_driver[GENPHY_DRV_10G].driver;
 		else
