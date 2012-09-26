From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] tcp: Remove unused parameter from tcp_v4_save_options
Date: Wed, 26 Sep 2012 23:59:09 +0200
Message-ID: <1348696749-29999-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59341 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab2IZV7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 17:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sock *sk is not used inside tcp_v4_save_options. Thus it can be
removed.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_ipv4.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93406c5..385eb79 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -925,8 +925,7 @@ EXPORT_SYMBOL(tcp_syn_flood_action);
 /*
  * Save and compile IPv4 options into the request_sock if needed.
  */
-static struct ip_options_rcu *tcp_v4_save_options(struct sock *sk,
-						  struct sk_buff *skb)
+static struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
 {
 	const struct ip_options *opt = &(IPCB(skb)->opt);
 	struct ip_options_rcu *dopt = NULL;
@@ -1568,7 +1567,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
-	ireq->opt = tcp_v4_save_options(sk, skb);
+	ireq->opt = tcp_v4_save_options(skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
-- 
1.7.9.5
