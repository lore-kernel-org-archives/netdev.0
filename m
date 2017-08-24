From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 08/13] net: mvpp2: check the netif is running in the link_event function
Date: Thu, 24 Aug 2017 10:38:18 +0200
Message-ID: <20170824083823.16826-9-antoine.tenart@free-electrons.com>
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

This patch adds an extra check when the link_event function is called,
so that it won't do anything when the netif isn't running.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 99847fec1c5a..e9fd4fa81a2e 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5741,6 +5741,9 @@ static void mvpp2_link_event(struct net_device *dev)
 	struct mvpp2_port *port = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 
+	if (!netif_running(dev))
+		return;
+
 	if (phydev->link) {
 		if ((port->speed != phydev->speed) ||
 		    (port->duplex != phydev->duplex)) {
-- 
2.13.5
