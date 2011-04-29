From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/10] ipv4: Get route daddr from flow key in
 ip4_datagram_connect().
Date: Fri, 29 Apr 2011 10:27:27 -0700 (PDT)
Message-ID: <20110429.102727.59668220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760510Ab1D2R2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:28:00 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2C3D124C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
destination address selection, we can fetch it from
fl4->daddr instead of rt->rt_dst

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/datagram.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index b7f583c..d5a2e69 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -69,7 +69,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
 	}
-	inet->inet_daddr = rt->rt_dst;
+	inet->inet_daddr = fl4.daddr;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
-- 
1.7.4.5

