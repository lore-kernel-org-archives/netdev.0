From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET]: should explicitely initialize atomic_t field in struct
 dst_ops
Date: Thu, 24 Jan 2008 16:11:17 +0100
Message-ID: <20080124161117.5727c45c.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40867 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbYAXPLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 10:11:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All but one struct dst_ops static initializations miss explicit
initialization of entries field.

As this field is atomic_t, we should use ATOMIC_INIT(0), and not
rely on atomic_t implementation.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv4/route.c        |    2 ++
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/route.c        |    2 ++
 net/ipv6/xfrm6_policy.c |    1 +
 4 files changed, 6 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 896c768..163086b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -169,6 +169,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.update_pmtu =		ip_rt_update_pmtu,
 	.local_out =		ip_local_out,
 	.entry_size =		sizeof(struct rtable),
+	.entries =		ATOMIC_INIT(0),
 };
 
 #define ECN_OR_COST(class)	TC_PRIO_##class
@@ -2498,6 +2499,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.check			=	ipv4_dst_check,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.entry_size		=	sizeof(struct rtable),
+	.entries		=	ATOMIC_INIT(0),
 };
 
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 3783e3e..10ed704 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -247,6 +247,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.local_out =		__ip_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
+	.entries =		ATOMIC_INIT(0),
 };
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4004c5f..8d669bb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -107,6 +107,7 @@ static struct dst_ops ip6_dst_ops = {
 	.update_pmtu		=	ip6_rt_update_pmtu,
 	.local_out		=	ip6_local_out,
 	.entry_size		=	sizeof(struct rt6_info),
+	.entries		=	ATOMIC_INIT(0),
 };
 
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -120,6 +121,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.check			=	ip6_dst_check,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.entry_size		=	sizeof(struct rt6_info),
+	.entries		=	ATOMIC_INIT(0),
 };
 
 struct rt6_info ip6_null_entry = {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c25a6b5..7d20199 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -272,6 +272,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.local_out =		__ip6_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
+	.entries =		ATOMIC_INIT(0),
 };
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
