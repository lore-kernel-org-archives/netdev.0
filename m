From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: kill circular reference with slave priv
Date: Mon, 18 Apr 2016 16:10:24 -0400
Message-ID: <1461010224-10808-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_slave_priv structure does not need a pointer to its net_device.
Kill it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 5 -----
 net/dsa/slave.c    | 9 ++++-----
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1d1a546..dfa3377 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -22,11 +22,6 @@ struct dsa_device_ops {
 };
 
 struct dsa_slave_priv {
-	/*
-	 * The linux network interface corresponding to this
-	 * switch port.
-	 */
-	struct net_device	*dev;
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2dae0d0..3b6750f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -673,10 +673,10 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	data[0] = p->dev->stats.tx_packets;
-	data[1] = p->dev->stats.tx_bytes;
-	data[2] = p->dev->stats.rx_packets;
-	data[3] = p->dev->stats.rx_bytes;
+	data[0] = dev->stats.tx_packets;
+	data[1] = dev->stats.tx_bytes;
+	data[2] = dev->stats.rx_packets;
+	data[3] = dev->stats.rx_bytes;
 	if (ds->drv->get_ethtool_stats != NULL)
 		ds->drv->get_ethtool_stats(ds, p->port, data + 4);
 }
@@ -1063,7 +1063,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-	p->dev = slave_dev;
 	p->parent = ds;
 	p->port = port;
 
-- 
2.8.0
