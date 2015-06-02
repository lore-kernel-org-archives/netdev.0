From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 1/9] net: dsa: add basic support for switchdev obj
Date: Mon,  1 Jun 2015 21:27:42 -0400
Message-ID: <1433208470-25338-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64414 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430AbbFBB2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 21:28:02 -0400
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the switchdev operations to add and delete switchdev
objects. This will be necessary to add fdb or VLAN entries.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad3..cbda00a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -363,6 +363,43 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 	return ret;
 }
 
+static int dsa_slave_port_obj_add(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	/*
+	 * Skip the prepare phase, since currently the DSA drivers don't need to
+	 * allocate any memory for operations and they will not fail to HW
+	 * (unless something horrible goes wrong on the MDIO bus, in which case
+	 * the prepare phase wouldn't have been able to predict anyway).
+	 */
+	if (obj->trans != SWITCHDEV_TRANS_COMMIT)
+		return 0;
+
+	switch (obj->id) {
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int dsa_slave_port_obj_del(struct net_device *dev,
+				  struct switchdev_obj *obj)
+{
+	int err;
+
+	switch (obj->id) {
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
@@ -702,6 +739,8 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
 	.switchdev_port_attr_get	= dsa_slave_port_attr_get,
 	.switchdev_port_attr_set	= dsa_slave_port_attr_set,
+	.switchdev_port_obj_add		= dsa_slave_port_obj_add,
+	.switchdev_port_obj_del		= dsa_slave_port_obj_del,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
-- 
2.4.1
