From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: Suffix function manipulating device_node with _dn
Date: Thu, 26 Jan 2017 10:28:07 -0800
Message-ID: <20170126182808.13435-4-f.fainelli@gmail.com>
References: <20170126182808.13435-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36271 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdAZShZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:37:25 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so16902383pfo.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:37:09 -0800 (PST)
In-Reply-To: <20170126182808.13435-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it clear that these functions take a device_node structure pointer

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 56c43ca7c049..4c11619a818b 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -93,8 +93,8 @@ static bool dsa_port_is_cpu(struct dsa_port *port)
 	return !!of_parse_phandle(port->dn, "ethernet", 0);
 }
 
-static bool dsa_ds_find_port(struct dsa_switch *ds,
-			     struct device_node *port)
+static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
+				struct device_node *port)
 {
 	u32 index;
 
@@ -104,8 +104,8 @@ static bool dsa_ds_find_port(struct dsa_switch *ds,
 	return false;
 }
 
-static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
-					    struct device_node *port)
+static struct dsa_switch *dsa_dst_find_port_dn(struct dsa_switch_tree *dst,
+					       struct device_node *port)
 {
 	struct dsa_switch *ds;
 	u32 index;
@@ -115,7 +115,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 		if (!ds)
 			continue;
 
-		if (dsa_ds_find_port(ds, port))
+		if (dsa_ds_find_port_dn(ds, port))
 			return ds;
 	}
 
@@ -136,7 +136,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 		if (!link)
 			break;
 
-		dst_ds = dsa_dst_find_port(dst, link);
+		dst_ds = dsa_dst_find_port_dn(dst, link);
 		of_node_put(link);
 
 		if (!dst_ds)
@@ -545,7 +545,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
-static int dsa_parse_member(struct device_node *np, u32 *tree, u32 *index)
+static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 {
 	int err;
 
@@ -591,7 +591,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	u32 tree, index;
 	int i, err;
 
-	err = dsa_parse_member(np, &tree, &index);
+	err = dsa_parse_member_dn(np, &tree, &index);
 	if (err)
 		return err;
 
-- 
2.9.3
