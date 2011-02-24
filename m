From: David Miller <davem@davemloft.net>
Subject: [PATCH 03/26] xfrm: Const'ify selector argument to
 xfrm_selector_match()
Date: Wed, 23 Feb 2011 23:13:05 -0800 (PST)
Message-ID: <20110223.231305.189699613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37453
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755782Ab1BXHM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 38C9424C089
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    2 +-
 net/xfrm/xfrm_policy.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 46f4470..567f08b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -845,7 +845,7 @@ __be16 xfrm_flowi_dport(const struct flowi *fl)
 	return port;
 }
 
-extern int xfrm_selector_match(struct xfrm_selector *sel,
+extern int xfrm_selector_match(const struct xfrm_selector *sel,
 			       const struct flowi *fl,
 			       unsigned short family);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 28c865a..4827c8d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -58,7 +58,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
 static inline int
-__xfrm4_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
+__xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
@@ -69,7 +69,7 @@ __xfrm4_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
 }
 
 static inline int
-__xfrm6_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
+__xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
@@ -79,7 +79,7 @@ __xfrm6_selector_match(struct xfrm_selector *sel, const struct flowi *fl)
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
 
-int xfrm_selector_match(struct xfrm_selector *sel, const struct flowi *fl,
+int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
 			unsigned short family)
 {
 	switch (family) {
-- 
1.7.4.1

