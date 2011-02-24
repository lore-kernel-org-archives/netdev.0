From: David Miller <davem@davemloft.net>
Subject: [PATCH 26/26] xfrm: Const'ify xfrm_address_t args to
 xfrm_state_find.
Date: Wed, 23 Feb 2011 23:17:57 -0800 (PST)
Message-ID: <20110223.231757.233700907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932769Ab1BXHRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:17:20 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9C29224C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This required a const'ification in xfrm_init_tempstate() too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |    4 ++--
 net/xfrm/xfrm_state.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3205e5e..44dccfc 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1334,8 +1334,8 @@ extern int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
 extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
 extern struct xfrm_state *xfrm_state_alloc(struct net *net);
-extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr,
-					  xfrm_address_t *saddr, 
+extern struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
+					  const xfrm_address_t *saddr,
 					  const struct flowi *fl,
 					  struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9d9ac7c..8496b3d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -659,7 +659,7 @@ EXPORT_SYMBOL(xfrm_sad_getinfo);
 static int
 xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 		    const struct xfrm_tmpl *tmpl,
-		    xfrm_address_t *daddr, xfrm_address_t *saddr,
+		    const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		    unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
@@ -790,7 +790,7 @@ static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
 }
 
 struct xfrm_state *
-xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
+xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		const struct flowi *fl, struct xfrm_tmpl *tmpl,
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
-- 
1.7.4.1

