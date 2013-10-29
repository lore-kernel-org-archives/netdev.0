From: <gregkh@linuxfoundation.org>
Subject: patch "mdio_bus: convert bus code to use dev_groups" added to driver-core tree
Date: Tue, 29 Oct 2013 16:25:56 -0700
Message-ID: <13830891561727@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
To: gregkh@linuxfoundation.org, broonie@opensource.wolfsonmicro.com,
	davem@davemloft.net, nbowler@elliptictech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39893 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3J2XZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:25:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    mdio_bus: convert bus code to use dev_groups

to my driver-core git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git
in the driver-core-next branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will also be merged in the next major kernel release
during the merge window.

If you have any questions about this process, please let me know.


>From 4192c74940e23da727eb02b7b4ee779dde2f670a Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 6 Oct 2013 23:55:41 -0700
Subject: mdio_bus: convert bus code to use dev_groups

The dev_attrs field of struct bus_type is going away soon, dev_groups
should be used instead.  This converts the MDIO bus code to use the
correct field.

Cc: David S. Miller <davem@davemloft.net>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>
Cc: Nick Bowler <nbowler@elliptictech.com>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/phy/mdio_bus.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index dc920974..56178761 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -438,17 +438,19 @@ phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
 
 	return sprintf(buf, "0x%.8lx\n", (unsigned long)phydev->phy_id);
 }
+static DEVICE_ATTR_RO(phy_id);
 
-static struct device_attribute mdio_dev_attrs[] = {
-	__ATTR_RO(phy_id),
-	__ATTR_NULL
+static struct attribute *mdio_dev_attrs[] = {
+	&dev_attr_phy_id.attr,
+	NULL,
 };
+ATTRIBUTE_GROUPS(mdio_dev);
 
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
 	.pm		= MDIO_BUS_PM_OPS,
-	.dev_attrs	= mdio_dev_attrs,
+	.dev_groups	= mdio_dev_groups,
 };
 EXPORT_SYMBOL(mdio_bus_type);
 
-- 
1.8.4.3.gca3854a
