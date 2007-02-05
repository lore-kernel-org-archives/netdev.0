From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] phy devices: use same arg types
Date: Mon, 5 Feb 2007 10:44:20 -0800
Message-ID: <20070205104420.4970ab1e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:52971 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933328AbXBESsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:48:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

sparse complains about differing types from prototype to
definition, so change the u32 to phy_interface_t:

drivers/net/phy/phy_device.c:140:19: error: symbol 'phy_connect' redeclared with different type (originally declared at include/linux/phy.h:362) - incompatible argument 5 (different signedness)
drivers/net/phy/phy_device.c:190:19: error: symbol 'phy_attach' redeclared with different type (originally declared at include/linux/phy.h:360) - incompatible argument 4 (different signedness)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/phy_device.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2620-pv.orig/drivers/net/phy/phy_device.c
+++ linux-2620-pv/drivers/net/phy/phy_device.c
@@ -139,7 +139,7 @@ void phy_prepare_link(struct phy_device 
  */
 struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
 		void (*handler)(struct net_device *), u32 flags,
-		u32 interface)
+		phy_interface_t interface)
 {
 	struct phy_device *phydev;
 
@@ -188,7 +188,7 @@ static int phy_compare_id(struct device 
 }
 
 struct phy_device *phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags, u32 interface)
+		const char *phy_id, u32 flags, phy_interface_t interface)
 {
 	struct bus_type *bus = &mdio_bus_type;
 	struct phy_device *phydev;
