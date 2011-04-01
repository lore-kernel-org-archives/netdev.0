From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7] ipv4: Use flowi4_init_output() in
 inet_connection_sock.c
Date: Thu, 31 Mar 2011 17:12:15 -0700 (PDT)
Message-ID: <20110331.171215.246525053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759531Ab1DAAMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 621BD24C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_connection_sock.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 6c0b7f4..f784608 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -356,20 +356,14 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options *opt = inet_rsk(req)->opt;
-	struct flowi4 fl4 = {
-		.flowi4_oif = sk->sk_bound_dev_if,
-		.flowi4_mark = sk->sk_mark,
-		.daddr = ((opt && opt->srr) ?
-			  opt->faddr : ireq->rmt_addr),
-		.saddr = ireq->loc_addr,
-		.flowi4_tos = RT_CONN_FLAGS(sk),
-		.flowi4_proto = sk->sk_protocol,
-		.flowi4_flags = inet_sk_flowi_flags(sk),
-		.fl4_sport = inet_sk(sk)->inet_sport,
-		.fl4_dport = ireq->rmt_port,
-	};
 	struct net *net = sock_net(sk);
+	struct flowi4 fl4;
 
+	flowi4_init_output(&fl4, sk->sk_bound_dev_if, sk->sk_mark,
+			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
+			   sk->sk_protocol, inet_sk_flowi_flags(sk),
+			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
+			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt))
-- 
1.7.4.2

