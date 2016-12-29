From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Implement ndo_get_phys_port_id
Date: Thu, 29 Dec 2016 14:20:56 -0800
Message-ID: <20161229222056.12490-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement ndo_get_phys_port_id() by returning the physical port number
of the switch this per-port DSA created network interface corresponds
to.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 68c9eea00518..ffd91969b830 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -984,6 +984,17 @@ static void dsa_slave_poll_controller(struct net_device *dev)
 }
 #endif
 
+static int dsa_slave_get_phys_port_id(struct net_device *dev,
+				      struct netdev_phys_item_id *ppid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	ppid->id_len = sizeof(p->port);
+	memcpy(ppid->id, &p->port, ppid->id_len);
+
+	return 0;
+}
+
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
 {
 	ops->get_sset_count = dsa_cpu_port_get_sset_count;
@@ -1031,6 +1042,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
+	.ndo_get_phys_port_id	= dsa_slave_get_phys_port_id,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
-- 
2.9.3
