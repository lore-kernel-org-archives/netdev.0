From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bridge: fix rcu check warning in multicast port
 group
Date: Sun, 4 Aug 2013 17:19:38 -0700
Message-ID: <20130804171938.0d515529@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56740 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984Ab3HEATm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 20:19:42 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2601707pdj.12
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 17:19:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of RCU here with out marked pointer and function doesn't match prototype
with sparse.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/bridge/br_mdb.c	2013-08-04 11:04:02.530470675 -0700
+++ b/net/bridge/br_mdb.c	2013-08-04 17:06:46.457182483 -0700
@@ -61,7 +61,8 @@ static int br_mdb_fill_info(struct sk_bu
 
 	for (i = 0; i < mdb->max; i++) {
 		struct net_bridge_mdb_entry *mp;
-		struct net_bridge_port_group *p, **pp;
+		struct net_bridge_port_group *p;
+		struct net_bridge_port_group __rcu **pp;
 		struct net_bridge_port *port;
 
 		hlist_for_each_entry_rcu(mp, &mdb->mhash[i], hlist[mdb->ver]) {
--- a/net/bridge/br_private.h	2013-08-04 11:04:02.534470627 -0700
+++ b/net/bridge/br_private.h	2013-08-04 17:02:29.972453140 -0700
@@ -466,7 +466,7 @@ extern void br_multicast_free_pg(struct
 extern struct net_bridge_port_group *br_multicast_new_port_group(
 				struct net_bridge_port *port,
 				struct br_ip *group,
-				struct net_bridge_port_group *next,
+				struct net_bridge_port_group __rcu *next,
 				unsigned char state);
 extern void br_mdb_init(void);
 extern void br_mdb_uninit(void);
