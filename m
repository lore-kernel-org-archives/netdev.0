From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/16] ipv4: Kill dst_copy_metrics() call from
 ipv4_blackhole_route().
Date: Tue, 10 Jul 2012 08:07:52 -0700 (PDT)
Message-ID: <20120710.080752.1968515537537191422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab2GJPHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:53 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C8F27586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Blackhole routes have a COW metrics operation that returns NULL
always, therefore this dst_copy_metrics() call did absolutely
nothing.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1678b57..a967df5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2668,7 +2668,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard;
-		dst_copy_metrics(new, &ort->dst);
 
 		new->dev = ort->dst.dev;
 		if (new->dev)
-- 
1.7.10.4
