From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 05/13] net: dsa: added dsa_net_device_to_dsa_port()
Date: Wed, 14 Jun 2017 13:26:38 +0200
Message-ID: <48444b4b8fa14962b372caaf5027782e@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta3.messagelabs.com ([195.245.230.177]:52560 "EHLO
        mail1.bemta3.messagelabs.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756573AbdGXPnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allowing dsa drivers to attach sysfs nodes.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
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


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
