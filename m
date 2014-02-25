From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] vxlan: remove unused port variable in vxlan_udp_encap_recv()
Date: Tue, 25 Feb 2014 17:46:10 +0100
Message-ID: <1393346770-25666-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60013 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbaBYQqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 11:46:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@gnumonks.org>

Signed-off-by: Pablo Neira Ayuso <pablo@gnumonks.org>
---
 drivers/net/vxlan.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index dec9820b..eb59b14 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1132,7 +1132,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
-	__be16 port;
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1150,8 +1149,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
 
-	port = inet_sk(sk)->inet_sport;
-
 	vs = rcu_dereference_sk_user_data(sk);
 	if (!vs)
 		goto drop;
-- 
1.7.10.4
