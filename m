From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/20] xfrm: Mark flowi arg to xfrm_selector_match() const.
Date: Tue, 22 Feb 2011 19:54:24 -0800 (PST)
Message-ID: <20110222.195424.39162189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32833
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756195Ab1BWDxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:47 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2F29B24C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    3 ++-
 net/xfrm/xfrm_policy.c |    8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2328532..b965ad7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -843,7 +843,8 @@ __be16 xfrm_flowi_dport(const struct flowi *fl)
 	return port;
 }
 
-extern int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
+extern int xfrm_selector_match(struct xfrm_selector *sel,
+			       const struct flowi *fl,
 			       unsigned short family);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ccd47cf..71e6dc2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -58,7 +58,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
 static inline int
-__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm4_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
@@ -69,7 +69,7 @@ __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 }
 
 static inline int
-__xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
+__xfrm6_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
@@ -79,8 +79,8 @@ __xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
 
-int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
-		    unsigned short family)
+int xfrm_selector_match(struct xfrm_selector *sel, const struct flowi *fl,
+			unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
-- 
1.7.4.1

