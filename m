From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: ip6_pkt_prohibit(_out) should not depend on CONFIG_IPV6_MULTIPLE_TABLES
Date: Thu, 28 Nov 2013 20:04:11 +0100
Message-ID: <20131128190411.GD24171@order.stressinduktion.org>
References: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since patch "IPv6: Fixed support for blackhole and prohibit routes" we
need ip6_pkt_prohibit(_out) available without CONFIG_IPV6_MULTIPLE_TABLES
defined.

Cc: Kamala R <kamala@aristanetworks.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 97125c4..ddb9d41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -84,6 +84,8 @@ static int		 ip6_dst_gc(struct dst_ops *ops);
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
+static int		ip6_pkt_prohibit(struct sk_buff *skb);
+static int		ip6_pkt_prohibit_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
@@ -234,9 +236,6 @@ static const struct rt6_info ip6_null_entry_template = {
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
-static int ip6_pkt_prohibit(struct sk_buff *skb);
-static int ip6_pkt_prohibit_out(struct sk_buff *skb);
-
 static const struct rt6_info ip6_prohibit_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
@@ -2147,8 +2146,6 @@ static int ip6_pkt_discard_out(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_OUTNOROUTES);
 }
 
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-
 static int ip6_pkt_prohibit(struct sk_buff *skb)
 {
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_INNOROUTES);
@@ -2160,8 +2157,6 @@ static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
 }
 
-#endif
-
 /*
  *	Allocate a dst for local (unicast / anycast) address.
  */
-- 
1.8.3.1
