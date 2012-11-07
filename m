From: Nick Bowler <nbowler@elliptictech.com>
Subject: [PATCH net-next] phylib: mdio: Add sysfs attribute for PHY identifiers.
Date: Wed,  7 Nov 2012 11:20:34 -0500
Message-ID: <1352305234-22340-1-git-send-email-nbowler@elliptictech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.scalarmail.ca ([98.158.95.75]:14457 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773Ab2KGQVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 11:21:24 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by sms-zimbra-mta-02.sms.scalar.ca (Postfix) with ESMTP id DFAEB87C1B
	for <netdev@vger.kernel.org>; Wed,  7 Nov 2012 11:21:23 -0500 (EST)
Received: from sms-zimbra-mta-02.sms.scalar.ca ([127.0.0.1])
	by localhost (sms-zimbra-mta-02.sms.scalar.ca [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yrxch9IXTB8K for <netdev@vger.kernel.org>;
	Wed,  7 Nov 2012 11:21:23 -0500 (EST)
Received: from mail.ellipticsemi.com (mail.elliptictech.com [209.217.122.41])
	(Authenticated sender: nbowler@elliptictech.com)
	by sms-zimbra-mta-02.sms.scalar.ca (Postfix) with ESMTPSA id DF48C87C0A
	for <netdev@vger.kernel.org>; Wed,  7 Nov 2012 11:21:22 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a phy_id sysfs attribute to MDIO devices, containing the
32-bit PHY identifier reported by the device.  This attribute can
be useful when debugging problems related to phy drivers.  Other
enumerable buses already have similar attributes.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
---
 Documentation/ABI/testing/sysfs-bus-mdio |    9 +++++++++
 drivers/net/phy/mdio_bus.c               |   14 ++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-bus-mdio

diff --git a/Documentation/ABI/testing/sysfs-bus-mdio b/Documentation/ABI/testing/sysfs-bus-mdio
new file mode 100644
index 000000000000..6349749ebc29
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-bus-mdio
@@ -0,0 +1,9 @@
+What:		/sys/bus/mdio_bus/devices/.../phy_id
+Date:		November 2012
+KernelVersion:	3.8
+Contact:	netdev@vger.kernel.org
+Description:
+		This attribute contains the 32-bit PHY Identifier as reported
+		by the device during bus enumeration, encoded in hexadecimal.
+		This ID is used to match the device with the appropriate
+		driver.
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index c1ef3000ea60..044b5326459f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -431,10 +431,24 @@ static struct dev_pm_ops mdio_bus_pm_ops = {
 
 #endif /* CONFIG_PM */
 
+static ssize_t
+phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	return sprintf(buf, "0x%.8lx\n", (unsigned long)phydev->phy_id);
+}
+
+static struct device_attribute mdio_dev_attrs[] = {
+	__ATTR_RO(phy_id),
+	__ATTR_NULL
+};
+
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
 	.pm		= MDIO_BUS_PM_OPS,
+	.dev_attrs	= mdio_dev_attrs,
 };
 EXPORT_SYMBOL(mdio_bus_type);
 
-- 
1.7.8.6
