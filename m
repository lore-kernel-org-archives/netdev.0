From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7] ipv4: Use flowi4_init_output() in udp_sendmsg()
Date: Thu, 31 Mar 2011 17:13:55 -0700 (PDT)
Message-ID: <20110331.171355.245403609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53127
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756205Ab1DAAOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:14:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 25D5224C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:13:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/udp.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 588f47a..ac66132 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -909,20 +909,14 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		struct flowi4 fl4 = {
-			.flowi4_oif = ipc.oif,
-			.flowi4_mark = sk->sk_mark,
-			.daddr = faddr,
-			.saddr = saddr,
-			.flowi4_tos = tos,
-			.flowi4_proto = sk->sk_protocol,
-			.flowi4_flags = (inet_sk_flowi_flags(sk) |
-					 FLOWI_FLAG_CAN_SLEEP),
-			.fl4_sport = inet->inet_sport,
-			.fl4_dport = dport,
-		};
+		struct flowi4 fl4;
 		struct net *net = sock_net(sk);
 
+		flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+				   inet_sk_flowi_flags(sk)|FLOWI_FLAG_CAN_SLEEP,
+				   faddr, saddr, dport, inet->inet_sport);
+
 		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
 		rt = ip_route_output_flow(net, &fl4, sk);
 		if (IS_ERR(rt)) {
-- 
1.7.4.2

