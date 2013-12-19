From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 2/5] xfrm: checkpatch errors with foo * bar
Date: Thu, 19 Dec 2013 20:22:11 +0800
Message-ID: <1387455734-7624-3-git-send-email-chenweilong@huawei.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7715 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab3LSMWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:22:40 -0500
In-Reply-To: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This patch clean up some checkpatch errors like this:
ERROR: "foo * bar" should be "foo *bar"
ERROR: "(foo*)" should be "(foo *)"

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_input.c  |  6 +++---
 net/xfrm/xfrm_policy.c | 12 ++++++------
 net/xfrm/xfrm_state.c  | 10 +++++-----
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 8884399..6c7ac01 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -67,7 +67,7 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 	case IPPROTO_COMP:
 		if (!pskb_may_pull(skb, sizeof(struct ip_comp_hdr)))
 			return -EINVAL;
-		*spi = htonl(ntohs(*(__be16*)(skb_transport_header(skb) + 2)));
+		*spi = htonl(ntohs(*(__be16 *)(skb_transport_header(skb) + 2)));
 		*seq = 0;
 		return 0;
 	default:
@@ -77,8 +77,8 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 	if (!pskb_may_pull(skb, hlen))
 		return -EINVAL;
 
-	*spi = *(__be32*)(skb_transport_header(skb) + offset);
-	*seq = *(__be32*)(skb_transport_header(skb) + offset_seq);
+	*spi = *(__be32 *)(skb_transport_header(skb) + offset);
+	*seq = *(__be32 *)(skb_transport_header(skb) + offset_seq);
 	return 0;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 439c6a1..e6f34de 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -176,7 +176,7 @@ static inline unsigned long make_jiffies(long secs)
 
 static void xfrm_policy_timer(unsigned long data)
 {
-	struct xfrm_policy *xp = (struct xfrm_policy*)data;
+	struct xfrm_policy *xp = (struct xfrm_policy *)data;
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -1753,7 +1753,7 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	}
 
 	xdst->num_pols = num_pols;
-	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy*) * num_pols);
+	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 	xdst->policy_genid = atomic_read(&pols[0]->genid);
 
 	return xdst;
@@ -2023,7 +2023,7 @@ make_dummy_bundle:
 	}
 	xdst->num_pols = num_pols;
 	xdst->num_xfrms = num_xfrms;
-	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy*) * num_pols);
+	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 
 	dst_hold(&xdst->u.dst);
 	return &xdst->flo;
@@ -2133,7 +2133,7 @@ restart:
 
 		num_pols = xdst->num_pols;
 		num_xfrms = xdst->num_xfrms;
-		memcpy(pols, xdst->pols, sizeof(struct xfrm_policy*) * num_pols);
+		memcpy(pols, xdst->pols, sizeof(struct xfrm_policy *) * num_pols);
 		route = xdst->route;
 	}
 
@@ -3069,8 +3069,8 @@ static bool xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
 	return false;
 }
 
-static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector *sel,
-						     u8 dir, u8 type)
+static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *sel,
+						    u8 dir, u8 type)
 {
 	struct xfrm_policy *pol, *ret = NULL;
 	struct hlist_head *chain;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5d31934..90dc310 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -386,7 +386,7 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
 
-static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
+static enum hrtimer_restart xfrm_timer_handler(struct hrtimer *me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
 	struct xfrm_state *x = container_of(thr, struct xfrm_state, mtimer);
@@ -1204,7 +1204,7 @@ out:
 }
 
 /* xfrm_state_lock is held */
-struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
+struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m)
 {
 	unsigned int h;
 	struct xfrm_state *x;
@@ -1247,8 +1247,8 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 }
 EXPORT_SYMBOL(xfrm_migrate_state_find);
 
-struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
-				       struct xfrm_migrate *m)
+struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
+				      struct xfrm_migrate *m)
 {
 	struct xfrm_state *xc;
 	int err;
@@ -1613,7 +1613,7 @@ EXPORT_SYMBOL(xfrm_state_walk_done);
 
 static void xfrm_replay_timer_handler(unsigned long data)
 {
-	struct xfrm_state *x = (struct xfrm_state*)data;
+	struct xfrm_state *x = (struct xfrm_state *)data;
 
 	spin_lock(&x->lock);
 
-- 
1.7.12
