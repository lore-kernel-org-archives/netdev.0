From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/10] ipv4: Get route daddr from flow key in
 tcp_v4_connect().
Date: Fri, 29 Apr 2011 10:27:39 -0700 (PDT)
Message-ID: <20110429.102739.48516624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760548Ab1D2R2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:28:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 650DA24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
destination address selection, we can fetch it from
fl4->daddr instead of rt->rt_dst

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3be00af..f3d16d8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -190,7 +190,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (!inet_opt || !inet_opt->opt.srr)
-		daddr = rt->rt_dst;
+		daddr = fl4.daddr;
 
 	if (!inet->inet_saddr)
 		inet->inet_saddr = fl4.saddr;
@@ -204,7 +204,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
-	    !tp->rx_opt.ts_recent_stamp && rt->rt_dst == daddr) {
+	    !tp->rx_opt.ts_recent_stamp && fl4.daddr == daddr) {
 		struct inet_peer *peer = rt_get_peer(rt);
 		/*
 		 * VJ's idea. We save last timestamp seen from
-- 
1.7.4.5

