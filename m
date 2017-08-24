From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 06/13] net: mvpp2: simplify the link_event function
Date: Thu, 24 Aug 2017 10:38:16 +0200
Message-ID: <20170824083823.16826-7-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link_event function is somewhat complicated. This cosmetic patch
simplifies it.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 49506bdde19a..ebcc89b8f792 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5740,7 +5740,6 @@ static void mvpp2_link_event(struct net_device *dev)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
-	int status_change = 0;
 
 	if (phydev->link) {
 		if ((port->speed != phydev->speed) ||
@@ -5751,23 +5750,19 @@ static void mvpp2_link_event(struct net_device *dev)
 	}
 
 	if (phydev->link != port->link) {
-		if (!phydev->link) {
-			port->duplex = -1;
-			port->speed = 0;
-		}
-
 		port->link = phydev->link;
-		status_change = 1;
-	}
 
-	if (status_change) {
 		if (phydev->link) {
 			mvpp2_egress_enable(port);
 			mvpp2_ingress_enable(port);
 		} else {
+			port->duplex = -1;
+			port->speed = 0;
+
 			mvpp2_ingress_disable(port);
 			mvpp2_egress_disable(port);
 		}
+
 		phy_print_status(phydev);
 	}
 }
-- 
2.13.5
