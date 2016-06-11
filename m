From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: fix endianness error in icmpv6_err
Date: Sat, 11 Jun 2016 20:32:06 +0200
Message-ID: <1465669926-16272-1-git-send-email-hannes@stressinduktion.org>
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44578 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751802AbcFKScq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 14:32:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 ping socket error handler doesn't correctly convert the new 32 bit
mtu to host endianness before using.

Cc: Lorenzo Colitti <lorenzo@google.com>
Fixes: 6d0bfe22611602f ("net: ipv6: Add IPv6 support to the ping socket.")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/icmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4527285fcaa2c2..a4fa840769690a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -98,7 +98,7 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (!(type & ICMPV6_INFOMSG_MASK))
 		if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
-			ping_err(skb, offset, info);
+			ping_err(skb, offset, ntohl(info));
 }
 
 static int icmpv6_rcv(struct sk_buff *skb);
-- 
2.5.5
