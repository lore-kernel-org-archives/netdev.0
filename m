From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/26] xfrm: Const'ify tmpl and address arguments to
 ->init_temprop()
Date: Wed, 23 Feb 2011 23:13:03 -0800 (PST)
Message-ID: <20110223.231303.104060535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab1BXHM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 29E3224C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    6 ++++--
 net/ipv4/xfrm4_state.c |    4 ++--
 net/ipv6/xfrm6_state.c |    4 ++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6ef5c37..46f4470 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -302,8 +302,10 @@ struct xfrm_state_afinfo {
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_selector *sel,
 						const struct flowi *fl);
-	void			(*init_temprop)(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
-						xfrm_address_t *daddr, xfrm_address_t *saddr);
+	void			(*init_temprop)(struct xfrm_state *x,
+						const struct xfrm_tmpl *tmpl,
+						const xfrm_address_t *daddr,
+						const xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 19eb560..983eff2 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -37,8 +37,8 @@ __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 }
 
 static void
-xfrm4_init_temprop(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
-		   xfrm_address_t *daddr, xfrm_address_t *saddr)
+xfrm4_init_temprop(struct xfrm_state *x, const struct xfrm_tmpl *tmpl,
+		   const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	x->id = tmpl->id;
 	if (x->id.daddr.a4 == 0)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 68a14c0..a02598e 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -38,8 +38,8 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 }
 
 static void
-xfrm6_init_temprop(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
-		   xfrm_address_t *daddr, xfrm_address_t *saddr)
+xfrm6_init_temprop(struct xfrm_state *x, const struct xfrm_tmpl *tmpl,
+		   const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	x->id = tmpl->id;
 	if (ipv6_addr_any((struct in6_addr*)&x->id.daddr))
-- 
1.7.4.1

