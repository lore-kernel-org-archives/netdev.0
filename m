From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/6] net: dsa: Suffix function manipulating device_node with _dn
Date: Mon, 27 Jun 2016 17:52:40 -0700
Message-ID: <1467075163-15890-4-git-send-email-f.fainelli@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33208 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbcF1AxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:53:03 -0400
Received: by mail-oi0-f68.google.com with SMTP id w141so269595oia.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:50 -0700 (PDT)
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it clear that these functions take a device_node structure pointer

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 3a782ceef716..bdde5d217326 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -110,8 +110,8 @@ static bool dsa_port_is_cpu(struct dsa_port *port)
 	return false;
 }
 
-static bool dsa_ds_find_port(struct dsa_switch *ds,
-			     struct device_node *port)
+static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
+				struct device_node *port)
 {
 	u32 index;
 
@@ -121,8 +121,8 @@ static bool dsa_ds_find_port(struct dsa_switch *ds,
 	return false;
 }
 
-static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
-					    struct device_node *port)
+static struct dsa_switch *dsa_dst_find_port_dn(struct dsa_switch_tree *dst,
+					       struct device_node *port)
 {
 	struct dsa_switch *ds;
 	u32 index;
@@ -132,7 +132,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 		if (!ds)
 			continue;
 
-		if (dsa_ds_find_port(ds, port))
+		if (dsa_ds_find_port_dn(ds, port))
 			return ds;
 	}
 
@@ -153,7 +153,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 		if (!link)
 			break;
 
-		dst_ds = dsa_dst_find_port(dst, link);
+		dst_ds = dsa_dst_find_port_dn(dst, link);
 		of_node_put(link);
 
 		if (!dst_ds)
@@ -557,7 +557,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
-static int dsa_parse_member(struct device_node *np, u32 *tree, u32 *index)
+static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 {
 	int err;
 
@@ -603,7 +603,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	u32 tree, index;
 	int err;
 
-	err = dsa_parse_member(np, &tree, &index);
+	err = dsa_parse_member_dn(np, &tree, &index);
 	if (err)
 		return err;
 
-- 
2.7.4
