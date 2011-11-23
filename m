From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] net: Rename the dst_opt default_mtu method to mtu
Date: Wed, 23 Nov 2011 13:12:51 +0100
Message-ID: <20111123121251.GB6348@secunet.com>
References: <20111123121213.GA6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53437 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181Ab1KWMM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 07:12:58 -0500
Content-Disposition: inline
In-Reply-To: <20111123121213.GA6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We plan to invoke the dst_opt->default_mtu() method unconditioally
from dst_mtu(). So rename the method to dst_opt->mtu() to match
the name with the new meaning.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    2 +-
 include/net/dst_ops.h  |    2 +-
 net/decnet/dn_route.c  |    6 +++---
 net/ipv4/route.c       |   10 +++++-----
 net/ipv6/route.c       |   10 +++++-----
 net/xfrm/xfrm_policy.c |    6 +++---
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 4fb6c43..666de31 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -208,7 +208,7 @@ static inline u32 dst_mtu(const struct dst_entry *dst)
 	u32 mtu = dst_metric_raw(dst, RTAX_MTU);
 
 	if (!mtu)
-		mtu = dst->ops->default_mtu(dst);
+		mtu = dst->ops->mtu(dst);
 
 	return mtu;
 }
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 9adb998..e1c2ee0 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -17,7 +17,7 @@ struct dst_ops {
 	int			(*gc)(struct dst_ops *ops);
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
 	unsigned int		(*default_advmss)(const struct dst_entry *);
-	unsigned int		(*default_mtu)(const struct dst_entry *);
+	unsigned int		(*mtu)(const struct dst_entry *);
 	u32 *			(*cow_metrics)(struct dst_entry *, unsigned long);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a77d161..db48679 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -112,7 +112,7 @@ static unsigned long dn_rt_deadline;
 static int dn_dst_gc(struct dst_ops *ops);
 static struct dst_entry *dn_dst_check(struct dst_entry *, __u32);
 static unsigned int dn_dst_default_advmss(const struct dst_entry *dst);
-static unsigned int dn_dst_default_mtu(const struct dst_entry *dst);
+static unsigned int dn_dst_mtu(const struct dst_entry *dst);
 static void dn_dst_destroy(struct dst_entry *);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
@@ -135,7 +135,7 @@ static struct dst_ops dn_dst_ops = {
 	.gc =			dn_dst_gc,
 	.check =		dn_dst_check,
 	.default_advmss =	dn_dst_default_advmss,
-	.default_mtu =		dn_dst_default_mtu,
+	.mtu =			dn_dst_mtu,
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		dn_dst_destroy,
 	.negative_advice =	dn_dst_negative_advice,
@@ -825,7 +825,7 @@ static unsigned int dn_dst_default_advmss(const struct dst_entry *dst)
 	return dn_mss_from_pmtu(dst->dev, dst_mtu(dst));
 }
 
-static unsigned int dn_dst_default_mtu(const struct dst_entry *dst)
+static unsigned int dn_dst_mtu(const struct dst_entry *dst)
 {
 	return dst->dev->mtu;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b17bf1..f1ac3ef 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -138,7 +138,7 @@ static int rt_chain_length_max __read_mostly	= 20;
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ipv4_default_advmss(const struct dst_entry *dst);
-static unsigned int	 ipv4_default_mtu(const struct dst_entry *dst);
+static unsigned int	 ipv4_mtu(const struct dst_entry *dst);
 static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
@@ -193,7 +193,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.gc =			rt_garbage_collect,
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
-	.default_mtu =		ipv4_default_mtu,
+	.mtu =			ipv4_mtu,
 	.cow_metrics =		ipv4_cow_metrics,
 	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
@@ -1814,7 +1814,7 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 	return advmss;
 }
 
-static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
+static unsigned int ipv4_mtu(const struct dst_entry *dst)
 {
 	unsigned int mtu = dst->dev->mtu;
 
@@ -2755,7 +2755,7 @@ static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 coo
 	return NULL;
 }
 
-static unsigned int ipv4_blackhole_default_mtu(const struct dst_entry *dst)
+static unsigned int ipv4_blackhole_mtu(const struct dst_entry *dst)
 {
 	return dst->dev->mtu;
 }
@@ -2775,7 +2775,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.protocol		=	cpu_to_be16(ETH_P_IP),
 	.destroy		=	ipv4_dst_destroy,
 	.check			=	ipv4_blackhole_dst_check,
-	.default_mtu		=	ipv4_blackhole_default_mtu,
+	.mtu			=	ipv4_blackhole_mtu,
 	.default_advmss		=	ipv4_default_advmss,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ipv4_rt_blackhole_cow_metrics,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d8fbd18..76645d7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -77,7 +77,7 @@ static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 				    const struct in6_addr *dest);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
-static unsigned int	 ip6_default_mtu(const struct dst_entry *dst);
+static unsigned int	 ip6_mtu(const struct dst_entry *dst);
 static struct dst_entry *ip6_negative_advice(struct dst_entry *);
 static void		ip6_dst_destroy(struct dst_entry *);
 static void		ip6_dst_ifdown(struct dst_entry *,
@@ -144,7 +144,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.gc_thresh		=	1024,
 	.check			=	ip6_dst_check,
 	.default_advmss		=	ip6_default_advmss,
-	.default_mtu		=	ip6_default_mtu,
+	.mtu			=	ip6_mtu,
 	.cow_metrics		=	ipv6_cow_metrics,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
@@ -155,7 +155,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
 
-static unsigned int ip6_blackhole_default_mtu(const struct dst_entry *dst)
+static unsigned int ip6_blackhole_mtu(const struct dst_entry *dst)
 {
 	return dst->dev->mtu;
 }
@@ -175,7 +175,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.protocol		=	cpu_to_be16(ETH_P_IPV6),
 	.destroy		=	ip6_dst_destroy,
 	.check			=	ip6_dst_check,
-	.default_mtu		=	ip6_blackhole_default_mtu,
+	.mtu			=	ip6_blackhole_mtu,
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
@@ -1041,7 +1041,7 @@ static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 	return mtu;
 }
 
-static unsigned int ip6_default_mtu(const struct dst_entry *dst)
+static unsigned int ip6_mtu(const struct dst_entry *dst)
 {
 	unsigned int mtu = IPV6_MIN_MTU;
 	struct inet6_dev *idev;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 552df27..b8be51e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2382,7 +2382,7 @@ static unsigned int xfrm_default_advmss(const struct dst_entry *dst)
 	return dst_metric_advmss(dst->path);
 }
 
-static unsigned int xfrm_default_mtu(const struct dst_entry *dst)
+static unsigned int xfrm_mtu(const struct dst_entry *dst)
 {
 	return dst_mtu(dst->path);
 }
@@ -2411,8 +2411,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->check = xfrm_dst_check;
 		if (likely(dst_ops->default_advmss == NULL))
 			dst_ops->default_advmss = xfrm_default_advmss;
-		if (likely(dst_ops->default_mtu == NULL))
-			dst_ops->default_mtu = xfrm_default_mtu;
+		if (likely(dst_ops->mtu == NULL))
+			dst_ops->mtu = xfrm_mtu;
 		if (likely(dst_ops->negative_advice == NULL))
 			dst_ops->negative_advice = xfrm_negative_advice;
 		if (likely(dst_ops->link_failure == NULL))
-- 
1.7.0.4
