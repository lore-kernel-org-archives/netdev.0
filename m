From: David Miller <davem@davemloft.net>
Subject: [PATCH 03/19] sunrpc: Don't do a dst_confirm() on an input routes.
Date: Tue, 03 Jul 2012 02:46:00 -0700 (PDT)
Message-ID: <20120703.024600.538440937217472470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab2GCJqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:00 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3C06858411D
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


xs_udp_data_ready() is operating on received packets, and tries to
do a dst_confirm() on the dst attached to the SKB.

This isn't right, dst confirmation is for output routes, not input
routes.  It's for resetting the timers on the nexthop neighbour entry
for the route, indicating that we've got good evidence that we've
successfully reached it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sunrpc/xprtsock.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 890b03f..62d0dac 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1014,9 +1014,6 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 
 	UDPX_INC_STATS_BH(sk, UDP_MIB_INDATAGRAMS);
 
-	/* Something worked... */
-	dst_confirm(skb_dst(skb));
-
 	xprt_adjust_cwnd(task, copied);
 	xprt_complete_rqst(task, copied);
 
-- 
1.7.10
