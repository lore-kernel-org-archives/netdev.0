From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/5] nfnetlink: remove nfnetlink_alloc_skb
Date: Thu, 18 Feb 2016 15:03:27 +0100
Message-ID: <1455804208-30512-5-git-send-email-fw@strlen.de>
References: <1455804208-30512-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50170 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946201AbcBRODy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 09:03:54 -0500
In-Reply-To: <1455804208-30512-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following mmapped netlink removal this code can be simplified by
removing the alloc wrapper.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter/nfnetlink.h | 2 --
 net/netfilter/nfnetlink.c           | 7 -------
 net/netfilter/nfnetlink_log.c       | 5 ++---
 3 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index ba0d978..1d82dd5 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -34,8 +34,6 @@ int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 int nfnetlink_has_listeners(struct net *net, unsigned int group);
-struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
-				    u32 dst_portid, gfp_t gfp_mask);
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags);
 int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index a7ba233..9a99f68 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -127,13 +127,6 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
-struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
-				    u32 dst_portid, gfp_t gfp_mask)
-{
-	return netlink_alloc_skb(net->nfnl, size, dst_portid, gfp_mask);
-}
-EXPORT_SYMBOL_GPL(nfnetlink_alloc_skb);
-
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags)
 {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 8ca9320..11f81c8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -330,14 +330,13 @@ nfulnl_alloc_skb(struct net *net, u32 peer_portid, unsigned int inst_size,
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = nfnetlink_alloc_skb(net, n, peer_portid, GFP_ATOMIC);
+	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
 			 * packet */
 
-			skb = nfnetlink_alloc_skb(net, pkt_size,
-						  peer_portid, GFP_ATOMIC);
+			skb = alloc_skb(pkt_size, GFP_ATOMIC);
 		}
 	}
 
-- 
2.4.10
