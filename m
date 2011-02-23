From: David Miller <davem@davemloft.net>
Subject: [PATCH 03/20] xfrm: Mark flowi arg to ->fill_dst() const.
Date: Tue, 22 Feb 2011 19:54:13 -0800 (PST)
Message-ID: <20110222.195413.104037691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756138Ab1BWDxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D57FD24C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h      |    2 +-
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_policy.c |    2 +-
 net/xfrm/xfrm_policy.c  |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2c0927b..c77407f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -279,7 +279,7 @@ struct xfrm_policy_afinfo {
 					     int nfheader_len);
 	int			(*fill_dst)(struct xfrm_dst *xdst,
 					    struct net_device *dev,
-					    struct flowi *fl);
+					    const struct flowi *fl);
 };
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index ef12e68..1e9844d 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -68,7 +68,7 @@ static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 }
 
 static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
-			  struct flowi *fl)
+			  const struct flowi *fl)
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 753e9a1..f2fa904 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -87,7 +87,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 }
 
 static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
-			  struct flowi *fl)
+			  const struct flowi *fl)
 {
 	struct rt6_info *rt = (struct rt6_info*)xdst->route;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f8ccb97..fa0b7f3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1369,7 +1369,7 @@ static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 }
 
 static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
-				struct flowi *fl)
+				const struct flowi *fl)
 {
 	struct xfrm_policy_afinfo *afinfo =
 		xfrm_policy_get_afinfo(xdst->u.dst.ops->family);
-- 
1.7.4.1

