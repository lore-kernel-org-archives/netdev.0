From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] libphy: add phy_find_first function
Date: Wed, 3 Feb 2010 16:34:31 +0100
Message-ID: <20100203153430.GB9266@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47015 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757219Ab0BCPee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 10:34:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many drivers do this in them manually. Now they can use this function.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index adbc0fd..db17945 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -277,6 +277,22 @@ int phy_device_register(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_device_register);
 
 /**
+ * phy_find_first - finds the first PHY device on the bus
+ * @bus: the target MII bus
+ */
+struct phy_device *phy_find_first(struct mii_bus *bus)
+{
+	int addr;
+
+	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
+		if (bus->phy_map[addr])
+			return bus->phy_map[addr];
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(phy_find_first);
+
+/**
  * phy_prepare_link - prepares the PHY layer to monitor link status
  * @phydev: target phy_device struct
  * @handler: callback function for link status change notifications
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6a7eb40..14d7fdf 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -452,6 +452,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		u32 flags, phy_interface_t interface);
 struct phy_device * phy_attach(struct net_device *dev,
 		const char *bus_id, u32 flags, phy_interface_t interface);
+struct phy_device *phy_find_first(struct mii_bus *bus);
 int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface);
