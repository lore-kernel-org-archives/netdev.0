From: David Miller <davem@davemloft.net>
Subject: [PATCH 02/20] xfrm: Mark flowi arg to ->get_tos() const.
Date: Tue, 22 Feb 2011 19:54:11 -0800 (PST)
Message-ID: <20110222.195411.71093603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756110Ab1BWDxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 24CF124C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:11 -0800 (PST)
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
index 2de3dae..2c0927b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -273,7 +273,7 @@ struct xfrm_policy_afinfo {
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
 						  int reverse);
-	int			(*get_tos)(struct flowi *fl);
+	int			(*get_tos)(const struct flowi *fl);
 	int			(*init_path)(struct xfrm_dst *path,
 					     struct dst_entry *dst,
 					     int nfheader_len);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 19fbdec..ef12e68 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -56,7 +56,7 @@ static int xfrm4_get_saddr(struct net *net,
 	return 0;
 }
 
-static int xfrm4_get_tos(struct flowi *fl)
+static int xfrm4_get_tos(const struct flowi *fl)
 {
 	return IPTOS_RT_MASK & fl->fl4_tos; /* Strip ECN bits */
 }
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 834dc02..753e9a1 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -67,7 +67,7 @@ static int xfrm6_get_saddr(struct net *net,
 	return 0;
 }
 
-static int xfrm6_get_tos(struct flowi *fl)
+static int xfrm6_get_tos(const struct flowi *fl)
 {
 	return 0;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7a8e2c7..f8ccb97 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1256,7 +1256,7 @@ xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, struct flowi *fl,
  * still valid.
  */
 
-static inline int xfrm_get_tos(struct flowi *fl, int family)
+static inline int xfrm_get_tos(const struct flowi *fl, int family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	int tos;
-- 
1.7.4.1

