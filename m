From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/10] ipv4: Fetch route saddr from flow key in
 tcp_v4_connect().
Date: Fri, 29 Apr 2011 10:27:11 -0700 (PDT)
Message-ID: <20110429.102711.112611047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760457Ab1D2R1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0220124C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
source address selection, we can fetch it from
fl4->saddr instead of rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d60732f..3be00af 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -193,7 +193,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		daddr = rt->rt_dst;
 
 	if (!inet->inet_saddr)
-		inet->inet_saddr = rt->rt_src;
+		inet->inet_saddr = fl4.saddr;
 	inet->inet_rcv_saddr = inet->inet_saddr;
 
 	if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
-- 
1.7.4.5

