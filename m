From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 4/8] net: dsa: change FDB routines prototypes
Date: Mon, 10 Aug 2015 09:09:49 -0400
Message-ID: <1439212193-7673-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:62761 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbHJNKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 09:10:15 -0400
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the prototype of port_getnext to include a vid parameter.

This is necessary to introduce the support for VLAN.

Also rename the fdb_{add,del,getnext} function pointers to
port_fdb_{add,del,getnext} since they are specific to a given port.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  6 +++---
 drivers/net/dsa/mv88e6352.c |  6 +++---
 drivers/net/dsa/mv88e6xxx.c |  2 +-
 drivers/net/dsa/mv88e6xxx.h |  2 +-
 include/net/dsa.h           | 17 +++++++++++------
 net/dsa/slave.c             | 16 +++++++++-------
 6 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1c78084..735f04c 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -116,9 +116,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge       = mv88e6xxx_join_bridge,
 	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
-	.fdb_add		= mv88e6xxx_port_fdb_add,
-	.fdb_del		= mv88e6xxx_port_fdb_del,
-	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index af210ef..191fb25 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -341,9 +341,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
-	.fdb_add		= mv88e6xxx_port_fdb_add,
-	.fdb_del		= mv88e6xxx_port_fdb_del,
-	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6615e9f..00f983b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1310,7 +1310,7 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 
 /* get next entry for port */
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static)
+			       unsigned char *addr, u16 *vid, bool *is_static)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index fd1125f..0cf470c 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -418,7 +418,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static);
+			       unsigned char *addr, u16 *vid, bool *is_static);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63b..6356f43 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -296,12 +296,17 @@ struct dsa_switch_driver {
 				     u32 br_port_mask);
 	int	(*port_stp_update)(struct dsa_switch *ds, int port,
 				   u8 state);
-	int	(*fdb_add)(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-	int	(*fdb_del)(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-	int	(*fdb_getnext)(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static);
+
+	/*
+	 * Forwarding database
+	 */
+	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid);
+	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid);
+	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
+				    unsigned char *addr, u16 *vid,
+				    bool *is_static);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0010c69..3d341b6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -208,8 +208,8 @@ static int dsa_slave_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (ds->drv->fdb_add)
-		ret = ds->drv->fdb_add(ds, p->port, addr, vid);
+	if (ds->drv->port_fdb_add)
+		ret = ds->drv->port_fdb_add(ds, p->port, addr, vid);
 
 	return ret;
 }
@@ -222,8 +222,8 @@ static int dsa_slave_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	struct dsa_switch *ds = p->parent;
 	int ret = -EOPNOTSUPP;
 
-	if (ds->drv->fdb_del)
-		ret = ds->drv->fdb_del(ds, p->port, addr, vid);
+	if (ds->drv->port_fdb_del)
+		ret = ds->drv->port_fdb_del(ds, p->port, addr, vid);
 
 	return ret;
 }
@@ -272,22 +272,24 @@ static int dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 	unsigned char addr[ETH_ALEN] = { 0 };
+	u16 vid = 0;
 	int ret;
 
-	if (!ds->drv->fdb_getnext)
+	if (!ds->drv->port_fdb_getnext)
 		return -EOPNOTSUPP;
 
 	for (; ; idx++) {
 		bool is_static;
 
-		ret = ds->drv->fdb_getnext(ds, p->port, addr, &is_static);
+		ret = ds->drv->port_fdb_getnext(ds, p->port, addr, &vid,
+						&is_static);
 		if (ret < 0)
 			break;
 
 		if (idx < cb->args[0])
 			continue;
 
-		ret = dsa_slave_fill_info(dev, skb, addr, 0,
+		ret = dsa_slave_fill_info(dev, skb, addr, vid,
 					  is_static,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq,
-- 
2.5.0
