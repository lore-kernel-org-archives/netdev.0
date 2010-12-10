From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next-2.6] ipv6: Fix 'release_it' logic in
 tcp_v6_get_peer()
Date: Fri, 10 Dec 2010 13:17:16 -0800 (PST)
Message-ID: <20101210.131716.02263228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752796Ab0LJVQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 16:16:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CF71824C08A
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 13:17:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We accidently set it to "true" for the case where we
are using a route bound peer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/tcp_ipv6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3194585..fee0768 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1877,7 +1877,7 @@ static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 		if (!rt->rt6i_peer)
 			rt6_bind_peer(rt, 1);
 		peer = rt->rt6i_peer;
-		*release_it = true;
+		*release_it = false;
 	}
 
 	return peer;
-- 
1.7.3.2

