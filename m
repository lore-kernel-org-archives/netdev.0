From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] inetpeer: Kill use of inet_peer_address_t typedef.
Date: Wed, 01 Dec 2010 17:29:59 -0800 (PST)
Message-ID: <20101201.172959.193697938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754600Ab0LBB3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 20:29:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2448024C088
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 17:29:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are verboten these days.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   12 ++++++------
 net/ipv4/inetpeer.c    |    8 ++++----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index fb8aeb1..5161bfd 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -14,18 +14,18 @@
 #include <net/ipv6.h>
 #include <asm/atomic.h>
 
-typedef struct {
+struct inetpeer_addr {
 	union {
 		__be32		a4;
 		__be32		a6[4];
 	};
 	__u16	family;
-} inet_peer_address_t;
+};
 
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer __rcu	*avl_left, *avl_right;
-	inet_peer_address_t	daddr;
+	struct inetpeer_addr	daddr;
 	__u32			avl_height;
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
@@ -51,11 +51,11 @@ struct inet_peer {
 void			inet_initpeers(void) __init;
 
 /* can be called with or without local BH being disabled */
-struct inet_peer	*inet_getpeer(inet_peer_address_t *daddr, int create);
+struct inet_peer	*inet_getpeer(struct inetpeer_addr *daddr, int create);
 
 static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 {
-	inet_peer_address_t daddr;
+	struct inetpeer_addr daddr;
 
 	daddr.a4 = v4daddr;
 	daddr.family = AF_INET;
@@ -64,7 +64,7 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 
 static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int create)
 {
-	inet_peer_address_t daddr;
+	struct inetpeer_addr daddr;
 
 	ipv6_addr_copy((struct in6_addr *)daddr.a6, v6daddr);
 	daddr.family = AF_INET6;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index f95b89f..d9bc857 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -161,8 +161,8 @@ static void unlink_from_unused(struct inet_peer *p)
 	}
 }
 
-static int addr_compare(const inet_peer_address_t *a,
-			const inet_peer_address_t *b)
+static int addr_compare(const struct inetpeer_addr *a,
+			const struct inetpeer_addr *b)
 {
 	int i, n = (a->family == AF_INET ? 1 : 4);
 
@@ -211,7 +211,7 @@ static int addr_compare(const inet_peer_address_t *a,
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu_bh(const inet_peer_address_t *daddr,
+static struct inet_peer *lookup_rcu_bh(const struct inetpeer_addr *daddr,
 				       struct inet_peer_base *base)
 {
 	struct inet_peer *u = rcu_dereference_bh(base->root);
@@ -472,7 +472,7 @@ static int cleanup_once(unsigned long ttl)
 }
 
 /* Called with or without local BH being disabled. */
-struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
+struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
 	struct inet_peer_base *base = family_to_base(AF_INET);
-- 
1.7.3.2

