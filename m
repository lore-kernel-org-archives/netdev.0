From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 6/6] xfrm: policy: make policy backend const
Date: Tue,  7 Feb 2017 15:00:19 +0100
Message-ID: <20170207140019.20269-7-fw@strlen.de>
References: <20170207140019.20269-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56654 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754499AbdBGOCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:02:17 -0500
In-Reply-To: <20170207140019.20269-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/xfrm4_policy.c |  2 +-
 net/ipv6/xfrm6_policy.c |  2 +-
 net/xfrm/xfrm_policy.c  | 18 +++++++++---------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 25613539766f..71b4ecc195c7 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -269,7 +269,7 @@ static struct dst_ops xfrm4_dst_ops_template = {
 	.gc_thresh =		INT_MAX,
 };
 
-static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
+static const struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.dst_ops =		&xfrm4_dst_ops_template,
 	.dst_lookup =		xfrm4_dst_lookup,
 	.get_saddr =		xfrm4_get_saddr,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3217e85334e3..79651bc71bf0 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -289,7 +289,7 @@ static struct dst_ops xfrm6_dst_ops_template = {
 	.gc_thresh =		INT_MAX,
 };
 
-static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
+static const struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.dst_ops =		&xfrm6_dst_ops_template,
 	.dst_lookup =		xfrm6_dst_lookup,
 	.get_saddr =		xfrm6_get_saddr,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 80ef0dcf0e29..04ed1a1ae019 100644
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
@@ -1426,7 +1426,7 @@ xfrm_get_saddr(struct net *net, int oif, xfrm_address_t *local,
 	       xfrm_address_t *remote, unsigned short family)
 {
 	int err;
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
@@ -1535,7 +1535,7 @@ xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, const struct flowi *fl,
 
 static int xfrm_get_tos(const struct flowi *fl, int family)
 {
-	struct xfrm_policy_afinfo *afinfo;
+	const struct xfrm_policy_afinfo *afinfo;
 	int tos = 0;
 
 	afinfo = xfrm_policy_get_afinfo(family);
@@ -1598,7 +1598,7 @@ static const struct flow_cache_ops xfrm_bundle_fc_ops = {
 
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
 
@@ -2201,7 +2201,7 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 static struct dst_entry *make_blackhole(struct net *net, u16 family,
 					struct dst_entry *dst_orig)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	struct dst_entry *ret;
 
 	if (!afinfo) {
@@ -2452,7 +2452,7 @@ xfrm_policy_ok(const struct xfrm_tmpl *tmpl, const struct sec_path *sp, int star
 int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 			  unsigned int family, int reverse)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	int err;
 
 	if (unlikely(afinfo == NULL))
-- 
2.10.2
