From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next v2 05/10] net: dsa: added dsa_net_device_to_dsa_port()
Date: Tue, 25 Jul 2017 18:15:48 +0200
Message-ID: <20170725161553.30147-6-privat@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allowing dsa drivers to attach sysfs nodes.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 include/net/dsa.h |  1 +
 net/dsa/slave.c   | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 88da272d20d0..a71c0a2401ee 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -450,6 +450,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 struct net_device *dsa_dev_to_net_device(struct device *dev);
+struct dsa_port *dsa_net_device_to_dsa_port(struct net_device *dev);
 
 /* Keep inline for faster access in hot path */
 static inline bool netdev_uses_dsa(struct net_device *dev)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9507bd38cf04..40410f1740de 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -209,6 +209,16 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
+struct dsa_port *dsa_net_device_to_dsa_port(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	if (!dsa_slave_dev_check(dev))
+		return NULL;
+	return p->dp;
+}
+EXPORT_SYMBOL_GPL(dsa_net_device_to_dsa_port);
+
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
-- 
2.11.0

