From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 2/8] mdio_bus: coding style fixes
Date: Sun, 5 Jan 2014 03:18:27 +0300
Message-ID: <201401050318.27852.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:63298 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbaADXS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:18:29 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so8921741lbi.38
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:18:28 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id mx3sm39484458lbc.14.2014.01.04.15.18.26
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:18:26 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent patch from Florian Fainelli fixed all 'checkpatch.pl' errors but left
some warnings like:

- including <asm/io.h> instead of <linux/io.h>;

- including <asm/uaccess.h> instead of <linux/uaccess.h>;

- block comments using empty /* line;

- 'struct dev_pm_ops' variable not being *const*.

While fixing these, also fix the following style issues (some of which were
found running 'checkpatch.pl --strict'):

- alignment not matching open paren;

- file name in the heading comment.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/mdio_bus.c |   27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -1,7 +1,4 @@
-/*
- * drivers/net/phy/mdio_bus.c
- *
- * MDIO Bus interface
+/* MDIO Bus interface
  *
  * Author: Andy Fleming
  *
@@ -36,10 +33,10 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
 
-#include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 /**
  * mdiobus_alloc_size - allocate a mii_bus structure
@@ -139,8 +136,7 @@ int mdiobus_register(struct mii_bus *bus
 	int i, err;
 
 	if (NULL == bus || NULL == bus->name ||
-			NULL == bus->read ||
-			NULL == bus->write)
+	    NULL == bus->read || NULL == bus->write)
 		return -EINVAL;
 
 	BUG_ON(bus->state != MDIOBUS_ALLOCATED &&
@@ -214,9 +210,7 @@ EXPORT_SYMBOL(mdiobus_unregister);
  */
 void mdiobus_free(struct mii_bus *bus)
 {
-	/*
-	 * For compatibility with error handling in drivers.
-	 */
+	/* For compatibility with error handling in drivers. */
 	if (bus->state == MDIOBUS_ALLOCATED) {
 		kfree(bus);
 		return;
@@ -335,15 +329,13 @@ static bool mdio_bus_phy_may_suspend(str
 	if (!netdev)
 		return true;
 
-	/*
-	 * Don't suspend PHY if the attched netdev parent may wakeup.
+	/* Don't suspend PHY if the attched netdev parent may wakeup.
 	 * The parent may point to a PCI device, as in tg3 driver.
 	 */
 	if (netdev->dev.parent && device_may_wakeup(netdev->dev.parent))
 		return false;
 
-	/*
-	 * Also don't suspend PHY if the netdev itself may wakeup. This
+	/* Also don't suspend PHY if the netdev itself may wakeup. This
 	 * is the case for devices w/o underlaying pwr. mgmt. aware bus,
 	 * e.g. SoC devices.
 	 */
@@ -358,8 +350,7 @@ static int mdio_bus_suspend(struct devic
 	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
 
-	/*
-	 * We must stop the state machine manually, otherwise it stops out of
+	/* We must stop the state machine manually, otherwise it stops out of
 	 * control, possibly with the phydev->lock held. Upon resume, netdev
 	 * may call phy routines that try to grab the same lock, and that may
 	 * lead to a deadlock.
@@ -415,7 +406,7 @@ static int mdio_bus_restore(struct devic
 	return 0;
 }
 
-static struct dev_pm_ops mdio_bus_pm_ops = {
+static const struct dev_pm_ops mdio_bus_pm_ops = {
 	.suspend = mdio_bus_suspend,
 	.resume = mdio_bus_resume,
 	.freeze = mdio_bus_suspend,
