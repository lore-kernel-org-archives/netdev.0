From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/20] xfrm: Mark flowi arg to xfrm_state_find() const.
Date: Tue, 22 Feb 2011 19:54:39 -0800 (PST)
Message-ID: <20110222.195439.260107348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752256Ab1BWDyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:02 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 553A224C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h    |    6 ++++--
 net/xfrm/xfrm_state.c |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b965ad7..bb824a5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1328,8 +1328,10 @@ extern int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
 extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
 extern struct xfrm_state *xfrm_state_alloc(struct net *net);
-extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
-					  struct flowi *fl, struct xfrm_tmpl *tmpl,
+extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr,
+					  xfrm_address_t *saddr, 
+					  const struct flowi *fl,
+					  struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
 					  unsigned short family);
 extern struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 674f278..30a0f17 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -785,7 +785,7 @@ static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_state *x,
 
 struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
-		struct flowi *fl, struct xfrm_tmpl *tmpl,
+		const struct flowi *fl, struct xfrm_tmpl *tmpl,
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
-- 
1.7.4.1

