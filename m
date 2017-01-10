From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/8] net: dsa: Suffix function manipulating device_node with _dn
Date: Tue, 10 Jan 2017 12:12:30 -0800
Message-ID: <20170110201235.21771-4-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36779 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964944AbdAJUNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:13:13 -0500
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it clear that these functions take a device_node structure pointer

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 91141ac6ec18..9089b3b1d7f5 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -112,8 +112,8 @@ static bool dsa_port_is_cpu(struct dsa_port *port)
 	return false;
 }
 
-static bool dsa_ds_find_port(struct dsa_switch *ds,
-			     struct device_node *port)
+static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
+				struct device_node *port)
 {
 	u32 index;
 
@@ -123,8 +123,8 @@ static bool dsa_ds_find_port(struct dsa_switch *ds,
 	return false;
 }
 
-static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
-					    struct device_node *port)
+static struct dsa_switch *dsa_dst_find_port_dn(struct dsa_switch_tree *dst,
+					       struct device_node *port)
 {
 	struct dsa_switch *ds;
 	u32 index;
@@ -134,7 +134,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 		if (!ds)
 			continue;
 
-		if (dsa_ds_find_port(ds, port))
+		if (dsa_ds_find_port_dn(ds, port))
 			return ds;
 	}
 
@@ -155,7 +155,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 		if (!link)
 			break;
 
-		dst_ds = dsa_dst_find_port(dst, link);
+		dst_ds = dsa_dst_find_port_dn(dst, link);
 		of_node_put(link);
 
 		if (!dst_ds)
@@ -559,7 +559,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
-static int dsa_parse_member(struct device_node *np, u32 *tree, u32 *index)
+static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 {
 	int err;
 
@@ -605,7 +605,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	u32 tree, index;
 	int i, err;
 
-	err = dsa_parse_member(np, &tree, &index);
+	err = dsa_parse_member_dn(np, &tree, &index);
 	if (err)
 		return err;
 
-- 
2.9.3
