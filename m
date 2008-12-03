From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv6/ip6mr.c: Use kmem_cache_zalloc, remove memset
Date: Wed, 03 Dec 2008 14:39:55 -0800
Message-ID: <1228343995.13046.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3140 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbYLCWjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 17:39:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/ip6mr.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index dfba9fd..f641eac 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -686,20 +686,18 @@ static struct mfc6_cache *ip6mr_cache_find(struct in6_addr *origin, struct in6_a
  */
 static struct mfc6_cache *ip6mr_cache_alloc(void)
 {
-	struct mfc6_cache *c = kmem_cache_alloc(mrt_cachep, GFP_KERNEL);
+	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 	if (c == NULL)
 		return NULL;
-	memset(c, 0, sizeof(*c));
 	c->mfc_un.res.minvif = MAXMIFS;
 	return c;
 }
 
 static struct mfc6_cache *ip6mr_cache_alloc_unres(void)
 {
-	struct mfc6_cache *c = kmem_cache_alloc(mrt_cachep, GFP_ATOMIC);
+	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
 	if (c == NULL)
 		return NULL;
-	memset(c, 0, sizeof(*c));
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10 * HZ;
 	return c;


