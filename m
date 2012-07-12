From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/16] net: Remove checks for dst_ops->redirect being NULL.
Date: Thu, 12 Jul 2012 01:12:38 -0700 (PDT)
Message-ID: <20120712.011238.1017310304152650486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826Ab2GLIMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:12:38 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8879F5824C8
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:12:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c         |    2 +-
 net/dccp/ipv6.c         |    2 +-
 net/ipv4/tcp_ipv4.c     |    2 +-
 net/ipv4/xfrm4_policy.c |    3 +--
 net/ipv6/ip6_tunnel.c   |    6 ++----
 net/ipv6/tcp_ipv6.c     |    2 +-
 net/sctp/input.c        |    2 +-
 7 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8f41a319..129ed8f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -199,7 +199,7 @@ static void dccp_do_redirect(struct sk_buff *skb, struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_check(sk, 0);
 
-	if (dst && dst->ops->redirect)
+	if (dst)
 		dst->ops->redirect(dst, skb);
 }
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b4d7d28..090c080 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -133,7 +133,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT) {
 		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
 
-		if (dst && dst->ops->redirect)
+		if (dst)
 			dst->ops->redirect(dst, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 087a848..7a0062c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -325,7 +325,7 @@ static void do_redirect(struct sk_buff *skb, struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_check(sk, 0);
 
-	if (dst && dst->ops->redirect)
+	if (dst)
 		dst->ops->redirect(dst, skb);
 }
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 258ebd7..737131c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -207,8 +207,7 @@ static void xfrm4_redirect(struct dst_entry *dst, struct sk_buff *skb)
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 	struct dst_entry *path = xdst->route;
 
-	if (path->ops->redirect)
-		path->ops->redirect(path, skb);
+	path->ops->redirect(path, skb);
 }
 
 static void xfrm4_dst_destroy(struct dst_entry *dst)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0b5b60e..61d1065 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -611,10 +611,8 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), rel_info);
 	}
-	if (rel_type == ICMP_REDIRECT) {
-		if (skb_dst(skb2)->ops->redirect)
-			skb_dst(skb2)->ops->redirect(skb_dst(skb2), skb2);
-	}
+	if (rel_type == ICMP_REDIRECT)
+		skb_dst(skb2)->ops->redirect(skb_dst(skb2), skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7249e4b..3071f37 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -366,7 +366,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT) {
 		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
 
-		if (dst && dst->ops->redirect)
+		if (dst)
 			dst->ops->redirect(dst,skb);
 	}
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5943b7d..f050d45 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -431,7 +431,7 @@ void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
 	if (!t)
 		return;
 	dst = sctp_transport_dst_check(t);
-	if (dst && dst->ops->redirect)
+	if (dst)
 		dst->ops->redirect(dst, skb);
 }
 
-- 
1.7.10.4
