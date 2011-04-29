From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/10] ipv4: Get route daddr from flow key in
 inet_csk_route_req().
Date: Fri, 29 Apr 2011 10:27:33 -0700 (PDT)
Message-ID: <20110429.102733.115922591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760532Ab1D2R2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:28:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 917E524C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
destination address selection, we can fetch it from
fl4->daddr instead of rt->rt_dst

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_connection_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3282cb2..54944da 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -367,7 +367,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && rt->rt_dst != rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && fl4.daddr != rt->rt_gateway)
 		goto route_err;
 	return &rt->dst;
 
-- 
1.7.4.5

