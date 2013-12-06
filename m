From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: don't count addrconf generated routes against gc limit
Date: Fri, 6 Dec 2013 18:25:56 +0100
Message-ID: <20131206172556.GF26746@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: brett.ciphery@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36665 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab3LFRZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:25:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brett Ciphery reported that new ipv6 addresses failed to get installed
because the addrconf generated dsts where counted against the dst gc
limit. We don't need to count those routes like we currently don't count
administratively added routes.

Because the max_addresses check enforces a limit on unbounded address
generation first in case someone plays with router advertisments, we
are still safe here.

Reported-by: Brett Ciphery <brett.ciphery@windriver.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddb9d41..11fdf1f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2166,7 +2166,8 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    bool anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
+	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
+					    DST_NOCOUNT, NULL);
 
 	if (!rt) {
 		net_warn_ratelimited("Maximum number of routes reached, consider increasing route/max_size\n");
-- 
1.8.3.1
