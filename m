From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 7 Aug 2012 11:51:06 -0500
Message-ID: <1344358266-5450-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <david.daney@cavium.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:19143
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755018Ab2HGQvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 12:51:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio-mux driver scans all child mdio nodes, without regard to whether
the node is actually used.  Some device trees include all possible
mdio-mux nodes and rely on the boot loader to disable those that are not
present, based on some run-time configuration.  Those nodes need to be
skipped.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/phy/mdio-mux.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 5c12018..d0c231e 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -135,6 +135,15 @@ int mdio_mux_init(struct device *dev,
 	for_each_child_of_node(dev->of_node, child_bus_node) {
 		u32 v;
 
+		/*
+		 * Some device trees include all possible mdio-mux nodes and
+		 * rely on the boot loader to disable those that are not
+		 * present, based on some run-time configuration.  Those nodes
+		 * need to be skipped.
+		 */
+		if (!of_device_is_available(child_bus_node))
+			continue;
+
 		r = of_property_read_u32(child_bus_node, "reg", &v);
 		if (r)
 			continue;
-- 
1.7.3.4
