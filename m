From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 08/10] net: phy: expose PHY device interface mode
Date: Tue, 11 Feb 2014 17:27:40 -0800
Message-ID: <1392168462-18888-9-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60332 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaBLB2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:30 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose the PHY device interface mode through sysfs since this is an
useful piece of information for knowing how the attached networking
device will have configured its transmit/receive path.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-bus-mdio | 10 ++++++++++
 drivers/net/phy/mdio_bus.c               | 10 ++++++++++
 2 files changed, 20 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-bus-mdio b/Documentation/ABI/testing/sysfs-bus-mdio
index 6349749..2133afd 100644
--- a/Documentation/ABI/testing/sysfs-bus-mdio
+++ b/Documentation/ABI/testing/sysfs-bus-mdio
@@ -7,3 +7,13 @@ Description:
 		by the device during bus enumeration, encoded in hexadecimal.
 		This ID is used to match the device with the appropriate
 		driver.
+
+What:		/sys/bus/mdio_bus/devices/.../phy_interface
+Date:		February 2014
+KernelVersion:	3.15
+Contact:	netdev@vger.kernel.org
+Description:
+		This attribute contains the PHY interface as configured by the
+		Ethernet driver during bus enumeration, encoded in string.
+		This interface mode is used to configure the Ethernet MAC with the
+		appropriate mode for its data lines to the PHY hardware.
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 71e4900..7c66ea0 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -432,8 +432,18 @@ phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
 }
 static DEVICE_ATTR_RO(phy_id);
 
+static ssize_t
+phy_interface_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	return sprintf(buf, "%s\n", phy_modes(phydev->interface));
+}
+static DEVICE_ATTR_RO(phy_interface);
+
 static struct attribute *mdio_dev_attrs[] = {
 	&dev_attr_phy_id.attr,
+	&dev_attr_phy_interface.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(mdio_dev);
-- 
1.8.3.2
