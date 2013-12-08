From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 4/5] ipv6: add ip6_flowlabel helper
Date: Sun,  8 Dec 2013 15:47:00 +0100
Message-ID: <1386514021-11646-4-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57313 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab3LHOrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 09:47:14 -0500
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And use it if possible.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h    | 5 +++++
 net/ipv6/ip6_gre.c    | 2 +-
 net/ipv6/ip6_tunnel.c | 2 +-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f0edf00..ff196b2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -678,6 +678,11 @@ static inline __be32 ip6_flowinfo(const struct ipv6hdr *hdr)
 	return *(__be32 *)hdr & IPV6_FLOWINFO_MASK;
 }
 
+static inline __be32 ip6_flowlabel(const struct ipv6hdr *hdr)
+{
+	return *(__be32 *)hdr & IPV6_FLOWLABEL_MASK;
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c50de06..e27fb78 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -845,7 +845,7 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
 		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
+		fl6.flowlabel |= ip6_flowlabel(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f5e8a98..8d7c986 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1130,7 +1130,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
 		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		fl6.flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
+		fl6.flowlabel |= ip6_flowlabel(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
-- 
1.8.4.3
