From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/10] ipv4: Get route daddr from flow key in
 l2tp_ip_connect().
Date: Fri, 29 Apr 2011 10:27:44 -0700 (PDT)
Message-ID: <20110429.102744.260100103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760554Ab1D2R2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:28:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B199724C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
destination address selection, we can fetch it from
fl4->daddr instead of rt->rt_dst

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_ip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index c100fa9..a4d2dfa 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -343,7 +343,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 		inet->inet_saddr = fl4.saddr;
 	if (!inet->inet_rcv_saddr)
 		inet->inet_rcv_saddr = fl4.saddr;
-	inet->inet_daddr = rt->rt_dst;
+	inet->inet_daddr = fl4.daddr;
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
 
-- 
1.7.4.5

