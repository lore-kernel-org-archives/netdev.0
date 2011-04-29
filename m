From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/10] ipv4: Fetch route saddr from flow key in
 ip4_datagram_connect().
Date: Fri, 29 Apr 2011 10:27:05 -0700 (PDT)
Message-ID: <20110429.102705.189715248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760435Ab1D2R1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E651024C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
source address selection, we can fetch it from
fl4->saddr instead of rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/datagram.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 216ba23..b7f583c 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -63,9 +63,9 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		return -EACCES;
 	}
 	if (!inet->inet_saddr)
-		inet->inet_saddr = rt->rt_src;	/* Update source address */
+		inet->inet_saddr = fl4.saddr;	/* Update source address */
 	if (!inet->inet_rcv_saddr) {
-		inet->inet_rcv_saddr = rt->rt_src;
+		inet->inet_rcv_saddr = fl4.saddr;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
 	}
-- 
1.7.4.5

