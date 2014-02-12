From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 10/10] net: phy: expose phydev->has_fixups to sysfs
Date: Tue, 11 Feb 2014 17:27:42 -0800
Message-ID: <1392168462-18888-11-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60332 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbaBLB2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:30 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose the PHY device has_fixups boolean as a sysfs property to help
troubleshooting PHY configurations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/ABI/testing/sysfs-bus-mdio | 11 +++++++++++
 drivers/net/phy/mdio_bus.c               | 10 ++++++++++
 2 files changed, 21 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-bus-mdio b/Documentation/ABI/testing/sysfs-bus-mdio
index 2133afd..fcab995 100644
--- a/Documentation/ABI/testing/sysfs-bus-mdio
+++ b/Documentation/ABI/testing/sysfs-bus-mdio
@@ -17,3 +17,14 @@ Description:
 		Ethernet driver during bus enumeration, encoded in string.
 		This interface mode is used to configure the Ethernet MAC with the
 		appropriate mode for its data lines to the PHY hardware.
+
+What:		/sys/bus/mdio_bus/devices/.../phy_has_fixups
+Date:		February 2014
+KernelVersion:	3.15
+Contact:	netdev@vger.kernel.org
+Description:
+		This attribute contains the boolean value whether a given PHY
+		device has had any "fixup" workaround running on it, encoded as
+		a boolean. This information is provided to help troubleshooting
+		PHY configurations.
+
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 7c66ea0..76f54b3 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -441,9 +441,19 @@ phy_interface_show(struct device *dev, struct device_attribute *attr, char *buf)
 }
 static DEVICE_ATTR_RO(phy_interface);
 
+static ssize_t
+phy_has_fixups_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	return sprintf(buf, "%d\n", phydev->has_fixups);
+}
+static DEVICE_ATTR_RO(phy_has_fixups);
+
 static struct attribute *mdio_dev_attrs[] = {
 	&dev_attr_phy_id.attr,
 	&dev_attr_phy_interface.attr,
+	&dev_attr_phy_has_fixups.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(mdio_dev);
-- 
1.8.3.2
