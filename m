From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/10] ipv4: Get route daddr from flow key in
 dccp_v4_connect().
Date: Fri, 29 Apr 2011 10:27:22 -0700 (PDT)
Message-ID: <20110429.102722.39169184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52413
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760490Ab1D2R1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A7D0A24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:27:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
destination address selection, we can fetch it from
fl4->daddr instead of rt->rt_dst

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index cbbcc6c..f4254bb 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -83,7 +83,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (inet_opt == NULL || !inet_opt->opt.srr)
-		daddr = rt->rt_dst;
+		daddr = fl4.daddr;
 
 	if (inet->inet_saddr == 0)
 		inet->inet_saddr = rt->rt_src;
-- 
1.7.4.5

