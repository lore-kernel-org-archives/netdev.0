From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] tcp: trivial: Remove nocache argument from tcp_v4_send_synack
Date: Sun, 18 Aug 2013 17:34:38 +0200
Message-ID: <1376840078-6556-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59053 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3HRPfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 11:35:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The nocache-argument was used in tcp_v4_send_synack as an argument to
inet_csk_route_req. However, since ba3f7f04ef2b (ipv4: Kill
FLOWI_FLAG_RT_NOCACHE and associated code.) this is no more used.

This patch removes the unsued argument from tcp_v4_send_synack.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_ipv4.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 05a3d45..09d45d7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -821,8 +821,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
-			      u16 queue_mapping,
-			      bool nocache)
+			      u16 queue_mapping)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -852,7 +851,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 
 static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
 {
-	int res = tcp_v4_send_synack(sk, NULL, req, 0, false);
+	int res = tcp_v4_send_synack(sk, NULL, req, 0);
 
 	if (!res)
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-- 
1.8.1.2
