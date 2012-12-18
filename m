From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: Correctly encode addresses when dumping mdb entries
Date: Tue, 18 Dec 2012 16:54:08 -0500
Message-ID: <1355867648-17316-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569Ab2LRVyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 16:54:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dumping mdb table, set the addresses the kernel returns
based on the address protocol type.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_mdb.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 9cf5d2b..ac22bb2 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -84,9 +84,11 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 					struct br_mdb_entry e;
 					e.ifindex = port->dev->ifindex;
 					e.state = p->state;
-					e.addr.u.ip4 = p->addr.u.ip4;
+					if (p->addr.proto == htons(ETH_P_IP))
+						e.addr.u.ip4 = p->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-					e.addr.u.ip6 = p->addr.u.ip6;
+					if (p->addr.proto == htons(ETH_P_IPV6))
+						e.addr.u.ip6 = p->addr.u.ip6;
 #endif
 					e.addr.proto = p->addr.proto;
 					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
-- 
1.7.7.6
