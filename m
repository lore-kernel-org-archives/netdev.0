From: akpm@osdl.org
Subject: [patch 9/9] net: uninline xfrm_selector_match()
Date: Wed, 08 Nov 2006 19:51:10 -0800
Message-ID: <200611090351.kA93pBEl003702@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, acme@mandriva.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16303 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965754AbWKIDvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:17 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

Six callsites, huge.

Cc: Arnaldo Carvalho de Melo <acme@mandriva.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/xfrm.h     |   36 ++----------------------------------
 net/xfrm/xfrm_policy.c |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 34 deletions(-)

diff -puN include/net/xfrm.h~net-uninline-xfrm_selector_match include/net/xfrm.h
--- a/include/net/xfrm.h~net-uninline-xfrm_selector_match
+++ a/include/net/xfrm.h
@@ -506,40 +506,8 @@ __be16 xfrm_flowi_dport(struct flowi *fl
 	return port;
 }
 
-static inline int
-__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
-{
-	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
-}
-
-static inline int
-__xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
-{
-	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
-		(fl->proto == sel->proto || !sel->proto) &&
-		(fl->oif == sel->ifindex || !sel->ifindex);
-}
-
-static inline int
-xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
-		    unsigned short family)
-{
-	switch (family) {
-	case AF_INET:
-		return __xfrm4_selector_match(sel, fl);
-	case AF_INET6:
-		return __xfrm6_selector_match(sel, fl);
-	}
-	return 0;
-}
+int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
+		    unsigned short family);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 /*	If neither has a context --> match
diff -puN net/xfrm/xfrm_policy.c~net-uninline-xfrm_selector_match net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c~net-uninline-xfrm_selector_match
+++ a/net/xfrm/xfrm_policy.c
@@ -50,6 +50,40 @@ static void xfrm_policy_put_afinfo(struc
 static struct xfrm_policy_afinfo *xfrm_policy_lock_afinfo(unsigned int family);
 static void xfrm_policy_unlock_afinfo(struct xfrm_policy_afinfo *afinfo);
 
+static inline int
+__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+{
+	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
+		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
+		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		(fl->proto == sel->proto || !sel->proto) &&
+		(fl->oif == sel->ifindex || !sel->ifindex);
+}
+
+static inline int
+__xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+{
+	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
+		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
+		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		(fl->proto == sel->proto || !sel->proto) &&
+		(fl->oif == sel->ifindex || !sel->ifindex);
+}
+
+int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
+		    unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return __xfrm4_selector_match(sel, fl);
+	case AF_INET6:
+		return __xfrm6_selector_match(sel, fl);
+	}
+	return 0;
+}
+
 int xfrm_register_type(struct xfrm_type *type, unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_lock_afinfo(family);
_
