From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] net: Remove protocol from struct dst_ops
Date: Mon, 09 Mar 2015 13:14:37 -0500
Message-ID: <87zj7m11iq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39973 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbbCISSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After my change to neigh_hh_init to obtain the protocol from the
neigh_table there are no more users of protocol in struct dst_ops.
Remove the protocol field from dst_ops and all of it's initializers.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/dst_ops.h   | 1 -
 net/bridge/br_nf_core.c | 1 -
 net/decnet/dn_route.c   | 1 -
 net/ipv4/route.c        | 2 --
 net/ipv4/xfrm4_policy.c | 1 -
 net/ipv6/route.c        | 2 --
 net/ipv6/xfrm6_policy.c | 1 -
 7 files changed, 9 deletions(-)

diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 1f99a1de0e4f..d64253914a6a 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -12,7 +12,6 @@ struct sock;
 
 struct dst_ops {
 	unsigned short		family;
-	__be16			protocol;
 	unsigned int		gc_thresh;
 
 	int			(*gc)(struct dst_ops *ops);
diff --git a/net/bridge/br_nf_core.c b/net/bridge/br_nf_core.c
index 387cb3bd017c..20cbb727df4d 100644
--- a/net/bridge/br_nf_core.c
+++ b/net/bridge/br_nf_core.c
@@ -54,7 +54,6 @@ static unsigned int fake_mtu(const struct dst_entry *dst)
 
 static struct dst_ops fake_dst_ops = {
 	.family		= AF_INET,
-	.protocol	= cpu_to_be16(ETH_P_IP),
 	.update_pmtu	= fake_update_pmtu,
 	.redirect	= fake_redirect,
 	.cow_metrics	= fake_cow_metrics,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 771815575dbd..9ab0c4ba297f 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -136,7 +136,6 @@ int decnet_dst_gc_interval = 2;
 
 static struct dst_ops dn_dst_ops = {
 	.family =		PF_DECnet,
-	.protocol =		cpu_to_be16(ETH_P_DNA_RT),
 	.gc_thresh =		128,
 	.gc =			dn_dst_gc,
 	.check =		dn_dst_check,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ad5064362c5c..649c8a3f0189 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -152,7 +152,6 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
-	.protocol =		cpu_to_be16(ETH_P_IP),
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
 	.mtu =			ipv4_mtu,
@@ -2225,7 +2224,6 @@ static u32 *ipv4_rt_blackhole_cow_metrics(struct dst_entry *dst,
 
 static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
-	.protocol		=	cpu_to_be16(ETH_P_IP),
 	.check			=	ipv4_blackhole_dst_check,
 	.mtu			=	ipv4_blackhole_mtu,
 	.default_advmss		=	ipv4_default_advmss,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6156f68a1e90..c224c856247b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -232,7 +232,6 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm4_dst_ops = {
 	.family =		AF_INET,
-	.protocol =		cpu_to_be16(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
 	.redirect =		xfrm4_redirect,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4688bd4d7f59..06fa819c43c9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -194,7 +194,6 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
-	.protocol		=	cpu_to_be16(ETH_P_IPV6),
 	.gc			=	ip6_dst_gc,
 	.gc_thresh		=	1024,
 	.check			=	ip6_dst_check,
@@ -236,7 +235,6 @@ static u32 *ip6_rt_blackhole_cow_metrics(struct dst_entry *dst,
 
 static struct dst_ops ip6_dst_blackhole_ops = {
 	.family			=	AF_INET6,
-	.protocol		=	cpu_to_be16(ETH_P_IPV6),
 	.destroy		=	ip6_dst_destroy,
 	.check			=	ip6_dst_check,
 	.mtu			=	ip6_blackhole_mtu,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 48bf5a06847b..8ddf2b545151 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -292,7 +292,6 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm6_dst_ops = {
 	.family =		AF_INET6,
-	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
 	.redirect =		xfrm6_redirect,
-- 
2.2.1
