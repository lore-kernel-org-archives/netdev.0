From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/20] xfrm: Kill strict arg to xfrm_bundle_ok().
Date: Tue, 22 Feb 2011 19:54:47 -0800 (PST)
Message-ID: <20110222.195447.28793916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32851
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753629Ab1BWDyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E7A3B24C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Always set to "0".

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 71e6dc2..1e11398 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -51,7 +51,7 @@ static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
-			  struct flowi *fl, int family, int strict);
+			  const struct flowi *fl, int family);
 
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -2210,7 +2210,7 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok(NULL, (struct xfrm_dst *)dst, NULL, AF_UNSPEC, 0);
+	return !xfrm_bundle_ok(NULL, (struct xfrm_dst *)dst, NULL, AF_UNSPEC);
 }
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
@@ -2283,7 +2283,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
  */
 
 static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
-		struct flowi *fl, int family, int strict)
+			  const struct flowi *fl, int family)
 {
 	struct dst_entry *dst = &first->u.dst;
 	struct xfrm_dst *last;
@@ -2320,11 +2320,6 @@ static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		    xdst->policy_genid != atomic_read(&xdst->pols[0]->genid))
 			return 0;
 
-		if (strict && fl &&
-		    !(dst->xfrm->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
-		    !xfrm_state_addr_flow_check(dst->xfrm, fl, family))
-			return 0;
-
 		mtu = dst_mtu(dst->child);
 		if (xdst->child_mtu_cached != mtu) {
 			last = xdst;
-- 
1.7.4.1

