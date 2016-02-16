From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/2] bridge: mdb: reduce the indentation level in br_mdb_fill_info
Date: Tue, 16 Feb 2016 12:46:53 +0100
Message-ID: <1455623214-2951-2-git-send-email-razor@blackwall.org>
References: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33447 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbcBPLrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 06:47:36 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so187637105wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 03:47:36 -0800 (PST)
In-Reply-To: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Switch the port check and skip if it's null, this allows us to reduce one
indentation level.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_mdb.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index ac089286526e..e66619171386 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -88,25 +88,26 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			for (pp = &mp->ports;
 			     (p = rcu_dereference(*pp)) != NULL;
 			      pp = &p->next) {
+				struct br_mdb_entry e;
+
 				port = p->port;
-				if (port) {
-					struct br_mdb_entry e;
-					memset(&e, 0, sizeof(e));
-					e.ifindex = port->dev->ifindex;
-					e.vid = p->addr.vid;
-					__mdb_entry_fill_flags(&e, p->flags);
-					if (p->addr.proto == htons(ETH_P_IP))
-						e.addr.u.ip4 = p->addr.u.ip4;
+				if (!port)
+					continue;
+				memset(&e, 0, sizeof(e));
+				e.ifindex = port->dev->ifindex;
+				e.vid = p->addr.vid;
+				__mdb_entry_fill_flags(&e, p->flags);
+				if (p->addr.proto == htons(ETH_P_IP))
+					e.addr.u.ip4 = p->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-					if (p->addr.proto == htons(ETH_P_IPV6))
-						e.addr.u.ip6 = p->addr.u.ip6;
+				if (p->addr.proto == htons(ETH_P_IPV6))
+					e.addr.u.ip6 = p->addr.u.ip6;
 #endif
-					e.addr.proto = p->addr.proto;
-					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
-						nla_nest_cancel(skb, nest2);
-						err = -EMSGSIZE;
-						goto out;
-					}
+				e.addr.proto = p->addr.proto;
+				if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
+					nla_nest_cancel(skb, nest2);
+					err = -EMSGSIZE;
+					goto out;
 				}
 			}
 			nla_nest_end(skb, nest2);
-- 
2.4.3
