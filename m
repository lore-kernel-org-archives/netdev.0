From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/26] xfrm: Const'ify ptr args to xfrm_state_*_check and
 xfrm_state_kern.
Date: Wed, 23 Feb 2011 23:16:01 -0800 (PST)
Message-ID: <20110223.231601.229752566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932371Ab1BXHPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:15:24 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D5C7124C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:16:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f6d2f63..3205e5e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1178,8 +1178,8 @@ void xfrm_flowi_addr_get(const struct flowi *fl,
 }
 
 static __inline__ int
-__xfrm4_state_addr_check(struct xfrm_state *x,
-			 xfrm_address_t *daddr, xfrm_address_t *saddr)
+__xfrm4_state_addr_check(const struct xfrm_state *x,
+			 const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	if (daddr->a4 == x->id.daddr.a4 &&
 	    (saddr->a4 == x->props.saddr.a4 || !saddr->a4 || !x->props.saddr.a4))
@@ -1188,8 +1188,8 @@ __xfrm4_state_addr_check(struct xfrm_state *x,
 }
 
 static __inline__ int
-__xfrm6_state_addr_check(struct xfrm_state *x,
-			 xfrm_address_t *daddr, xfrm_address_t *saddr)
+__xfrm6_state_addr_check(const struct xfrm_state *x,
+			 const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	if (!ipv6_addr_cmp((struct in6_addr *)daddr, (struct in6_addr *)&x->id.daddr) &&
 	    (!ipv6_addr_cmp((struct in6_addr *)saddr, (struct in6_addr *)&x->props.saddr)|| 
@@ -1200,8 +1200,8 @@ __xfrm6_state_addr_check(struct xfrm_state *x,
 }
 
 static __inline__ int
-xfrm_state_addr_check(struct xfrm_state *x,
-		      xfrm_address_t *daddr, xfrm_address_t *saddr,
+xfrm_state_addr_check(const struct xfrm_state *x,
+		      const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		      unsigned short family)
 {
 	switch (family) {
@@ -1214,23 +1214,23 @@ xfrm_state_addr_check(struct xfrm_state *x,
 }
 
 static __inline__ int
-xfrm_state_addr_flow_check(struct xfrm_state *x, const struct flowi *fl,
+xfrm_state_addr_flow_check(const struct xfrm_state *x, const struct flowi *fl,
 			   unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
 		return __xfrm4_state_addr_check(x,
-						(xfrm_address_t *)&fl->fl4_dst,
-						(xfrm_address_t *)&fl->fl4_src);
+						(const xfrm_address_t *)&fl->fl4_dst,
+						(const xfrm_address_t *)&fl->fl4_src);
 	case AF_INET6:
 		return __xfrm6_state_addr_check(x,
-						(xfrm_address_t *)&fl->fl6_dst,
-						(xfrm_address_t *)&fl->fl6_src);
+						(const xfrm_address_t *)&fl->fl6_dst,
+						(const xfrm_address_t *)&fl->fl6_src);
 	}
 	return 0;
 }
 
-static inline int xfrm_state_kern(struct xfrm_state *x)
+static inline int xfrm_state_kern(const struct xfrm_state *x)
 {
 	return atomic_read(&x->tunnel_users);
 }
-- 
1.7.4.1

