From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 14/20] inet: prepare net on the stack for NET accounting macros
Date: Wed, 16 Jul 2008 12:29:09 +0400
Message-ID: <487DB155.4070109@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52840 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757794AbYGPI3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:29:14 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/dccp/ipv6.c     |    3 ++-
 net/ipv4/arp.c      |    3 ++-
 net/ipv6/tcp_ipv6.c |    3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index eec3c47..83cc9bb 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -93,8 +93,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sock *sk;
 	int err;
 	__u64 seq;
+	struct net *net = dev_net(skb->dev);
 
-	sk = inet6_lookup(dev_net(skb->dev), &dccp_hashinfo,
+	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 29df75a..aab98b8 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -421,8 +421,9 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	struct rtable *rt;
 	int flag = 0;
 	/*unsigned long now; */
+	struct net *net = dev_net(dev);
 
-	if (ip_route_output_key(dev_net(dev), &rt, &fl) < 0)
+	if (ip_route_output_key(net, &rt, &fl) < 0)
 		return 1;
 	if (rt->u.dst.dev != dev) {
 		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3895d91..d58b83a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -323,8 +323,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	struct tcp_sock *tp;
 	__u32 seq;
+	struct net *net = dev_net(skb->dev);
 
-	sk = inet6_lookup(dev_net(skb->dev), &tcp_hashinfo, &hdr->daddr,
+	sk = inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
 			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
 	if (sk == NULL) {
-- 
1.5.5.1

