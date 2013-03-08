From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 4/4] ipv6: report sin6_scope_id if sockopt RECVORIGDSTADDR is set
Date: Fri, 8 Mar 2013 13:07:26 +0100
Message-ID: <20130308120726.GA5174@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51156 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757097Ab3CHMH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 07:07:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4:
a) unchanged

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/datagram.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b55e70a..4b56cbb 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -594,7 +594,9 @@ int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
 			sin6.sin6_addr = ipv6_hdr(skb)->daddr;
 			sin6.sin6_port = ports[1];
 			sin6.sin6_flowinfo = 0;
-			sin6.sin6_scope_id = 0;
+			sin6.sin6_scope_id =
+				ipv6_iface_scope_id(&ipv6_hdr(skb)->daddr,
+						    opt->iif);
 
 			put_cmsg(msg, SOL_IPV6, IPV6_ORIGDSTADDR, sizeof(sin6), &sin6);
 		}
-- 
1.8.1.4
