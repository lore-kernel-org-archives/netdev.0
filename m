From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 07/13] xfrm: policy: make policy backend const
Date: Thu, 16 Feb 2017 13:18:41 +0100
Message-ID: <1487247527-17925-8-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49312 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754386AbdBPMTA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:19:00 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |  2 +-
 net/ipv6/xfrm6_policy.c |  2 +-
 net/xfrm/xfrm_policy.c  | 18 +++++++++---------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 2561353..71b4ecc1 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -269,7 +269,7 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	.gc_thresh =		INT_MAX,
 };
 
-static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
+static const struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.dst_ops =		&xfrm4_dst_ops_template,
 	.dst_lookup =		xfrm4_dst_lookup,
 	.get_saddr =		xfrm4_get_saddr,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3217e85..79651bc 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -289,7 +289,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	.gc_thresh =		INT_MAX,
 };
 
-static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
+static const struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.dst_ops =		&xfrm6_dst_ops_template,
 	.dst_lookup =		xfrm6_dst_lookup,
 	.get_saddr =		xfrm6_get_saddr,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 80ef0dc..04ed1a1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -45,7 +45,7 @@ struct xfrm_flo {
 };
 
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
-static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
+static struct xfrm_policy_afinfo const __rcu *xfrm_policy_afinfo[AF_INET6 + 1]
 						__read_mostly;
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
@@ -122,7 +122,7 @@ static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
 						  const xfrm_address_t *daddr,
 						  int family)
 {
-	struct xfrm_policy_afinfo *afinfo;
+	const struct xfrm_policy_afinfo *afinfo;
 	struct dst_entry *dst;
 
 	afinfo = xfrm_policy_get_afinfo(family);
@@ -1426,7 +1426,7 @@ int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 	       xfrm_address_t *remote, unsigned short family)
 {
 	int err;
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
@@ -1535,7 +1535,7 @@ int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 
 static int xfrm_get_tos(const struct flowi *fl, int family)
 {
-	struct xfrm_policy_afinfo *afinfo;
+	const struct xfrm_policy_afinfo *afinfo;
 	int tos = 0;
 
 	afinfo = xfrm_policy_get_afinfo(family);
@@ -1598,7 +1598,7 @@ static void xfrm_bundle_flo_delete(struct flow_cache_object *flo)
 
 static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	struct dst_ops *dst_ops;
 	struct xfrm_dst *xdst;
 
@@ -1635,7 +1635,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 				 int nfheader_len)
 {
-	struct xfrm_policy_afinfo *afinfo =
+	const struct xfrm_policy_afinfo *afinfo =
 		xfrm_policy_get_afinfo(dst->ops->family);
 	int err;
 
@@ -1652,7 +1652,7 @@ static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 				const struct flowi *fl)
 {
-	struct xfrm_policy_afinfo *afinfo =
+	const struct xfrm_policy_afinfo *afinfo =
 		xfrm_policy_get_afinfo(xdst->u.dst.ops->family);
 	int err;
 
@@ -2201,7 +2201,7 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 static struct dst_entry *make_blackhole(struct net *net, u16 family,
 					struct dst_entry *dst_orig)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	struct dst_entry *ret;
 
 	if (!afinfo) {
@@ -2452,7 +2452,7 @@ struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
 int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 			  unsigned int family, int reverse)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	int err;
 
 	if (unlikely(afinfo == NULL))
-- 
1.9.1
