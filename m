From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/16] net: Add dummy dst_ops->redirect method where needed.
Date: Thu, 12 Jul 2012 01:12:27 -0700 (PDT)
Message-ID: <20120712.011227.770452085410994790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932983Ab2GLIM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:12:28 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 405045824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:12:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_netfilter.c |    5 +++++
 net/decnet/dn_route.c     |    6 ++++++
 net/ipv4/route.c          |    5 +++++
 net/ipv6/route.c          |    5 +++++
 4 files changed, 21 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index b98d3d7..81f76c4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -115,6 +115,10 @@ static void fake_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
 
+static void fake_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+}
+
 static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	return NULL;
@@ -136,6 +140,7 @@ static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
+	.redirect =		fake_redirect,
 	.cow_metrics =		fake_cow_metrics,
 	.neigh_lookup =		fake_neigh_lookup,
 	.mtu =			fake_mtu,
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b5594cc..e9c4e2e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -118,6 +118,7 @@ static void dn_dst_ifdown(struct dst_entry *, struct net_device *dev, int how);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
+static void dn_dst_redirect(struct dst_entry *dst, struct sk_buff *skb);
 static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst,
 					     struct sk_buff *skb,
 					     const void *daddr);
@@ -145,6 +146,7 @@ static struct dst_ops dn_dst_ops = {
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
+	.redirect =		dn_dst_redirect,
 	.neigh_lookup =		dn_dst_neigh_lookup,
 };
 
@@ -292,6 +294,10 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
+static void dn_dst_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+}
+
 /*
  * When a route has been marked obsolete. (e.g. routing cache flush)
  */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e98207d..23bbe29 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2591,6 +2591,10 @@ static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
 
+static void ipv4_rt_blackhole_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+}
+
 static u32 *ipv4_rt_blackhole_cow_metrics(struct dst_entry *dst,
 					  unsigned long old)
 {
@@ -2605,6 +2609,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.mtu			=	ipv4_blackhole_mtu,
 	.default_advmss		=	ipv4_default_advmss,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
+	.redirect		=	ipv4_rt_blackhole_redirect,
 	.cow_metrics		=	ipv4_rt_blackhole_cow_metrics,
 	.neigh_lookup		=	ipv4_neigh_lookup,
 };
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7296af1..3151aab 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -191,6 +191,10 @@ static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
 
+static void ip6_rt_blackhole_redirect(struct dst_entry *dst, struct sk_buff *skb)
+{
+}
+
 static u32 *ip6_rt_blackhole_cow_metrics(struct dst_entry *dst,
 					 unsigned long old)
 {
@@ -205,6 +209,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.mtu			=	ip6_blackhole_mtu,
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
+	.redirect		=	ip6_rt_blackhole_redirect,
 	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };
-- 
1.7.10.4
