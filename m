From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/20] xfrm: Mark flowi arg to ->init_tempsel() const.
Date: Tue, 22 Feb 2011 19:54:16 -0800 (PST)
Message-ID: <20110222.195416.189722353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756147Ab1BWDxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:39 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7043424C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    3 ++-
 net/ipv4/xfrm4_state.c |    2 +-
 net/ipv6/xfrm6_state.c |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c77407f..614c296 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -300,7 +300,8 @@ struct xfrm_state_afinfo {
 	const struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
-	void			(*init_tempsel)(struct xfrm_selector *sel, struct flowi *fl);
+	void			(*init_tempsel)(struct xfrm_selector *sel,
+						const struct flowi *fl);
 	void			(*init_temprop)(struct xfrm_state *x, struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 4794762..19eb560 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -21,7 +21,7 @@ static int xfrm4_init_flags(struct xfrm_state *x)
 }
 
 static void
-__xfrm4_init_tempsel(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	sel->daddr.a4 = fl->fl4_dst;
 	sel->saddr.a4 = fl->fl4_src;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index a67575d..68a14c0 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -20,7 +20,7 @@
 #include <net/addrconf.h>
 
 static void
-__xfrm6_init_tempsel(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	/* Initialize temporary selector matching only
 	 * to current session. */
-- 
1.7.4.1

