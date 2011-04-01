From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7] ipv4: Use flowi4_init_output() in ip_send_reply()
Date: Thu, 31 Mar 2011 17:12:17 -0700 (PDT)
Message-ID: <20110331.171217.28805938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759531Ab1DAAMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CF04224C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 67f241b..86a2843 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1474,16 +1474,14 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	}
 
 	{
-		struct flowi4 fl4 = {
-			.flowi4_oif = arg->bound_dev_if,
-			.daddr = daddr,
-			.saddr = rt->rt_spec_dst,
-			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
-			.fl4_sport = tcp_hdr(skb)->dest,
-			.fl4_dport = tcp_hdr(skb)->source,
-			.flowi4_proto = sk->sk_protocol,
-			.flowi4_flags = ip_reply_arg_flowi_flags(arg),
-		};
+		struct flowi4 fl4;
+
+		flowi4_init_output(&fl4, arg->bound_dev_if, 0,
+				   RT_TOS(ip_hdr(skb)->tos),
+				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+				   ip_reply_arg_flowi_flags(arg),
+				   daddr, rt->rt_spec_dst,
+				   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
 		security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 		rt = ip_route_output_key(sock_net(sk), &fl4);
 		if (IS_ERR(rt))
-- 
1.7.4.2

