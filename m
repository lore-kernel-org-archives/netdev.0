From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/10] ipv4: Fetch route saddr from flow key in
 l2tp_ip_connect().
Date: Fri, 29 Apr 2011 10:27:16 -0700 (PDT)
Message-ID: <20110429.102716.183035930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760459Ab1D2R1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:49 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DAC2C24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
source address selection, we can fetch it from
fl4->saddr instead of rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_ip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index e13c166..c100fa9 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -340,9 +340,9 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	l2tp_ip_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
 
 	if (!inet->inet_saddr)
-		inet->inet_saddr = rt->rt_src;
+		inet->inet_saddr = fl4.saddr;
 	if (!inet->inet_rcv_saddr)
-		inet->inet_rcv_saddr = rt->rt_src;
+		inet->inet_rcv_saddr = fl4.saddr;
 	inet->inet_daddr = rt->rt_dst;
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
-- 
1.7.4.5

