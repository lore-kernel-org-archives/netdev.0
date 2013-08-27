From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6:examine the IP source address legitimacy
Date: Tue, 27 Aug 2013 19:42:24 +0800
Message-ID: <521C90A0.60708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:40320 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab3H0Lm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 07:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

RFC4861 8.1:
The IP source address of the Redirect is the
same as the current first-hop router for the
specified ICMP Destination Address.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8d9a93e..d4f0f72 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1685,6 +1685,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct netevent_redirect netevent;
 	struct rt6_info *rt, *nrt = NULL;
 	struct ndisc_options ndopts;
@@ -1745,7 +1746,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	}
 
 	rt = (struct rt6_info *) dst;
-	if (rt == net->ipv6.ip6_null_entry) {
+	if (rt == net->ipv6.ip6_null_entry || !ipv6_addr_equal(&rt->rt6i_gateway, &iph->saddr)) {
 		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
 		return;
 	}
-- 
1.8.3.1
