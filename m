From: David Miller <davem@davemloft.net>
Subject: ipv6: Demark default hoplimit as zero.
Date: Mon, 13 Dec 2010 10:03:25 -0800 (PST)
Message-ID: <20101213.100325.183062004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758482Ab0LMSC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:02:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5358224C088
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 10:03:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is for consistency with ipv4.  Using "-1" makes
no sense.

It was made this way a long time ago merely to be consistent
with how the ipv6 socket hoplimit "default" is stored.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d9405d1..98796b0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1105,7 +1105,7 @@ static int ipv6_get_mtu(struct net_device *dev)
 int ip6_dst_hoplimit(struct dst_entry *dst)
 {
 	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
-	if (hoplimit < 0) {
+	if (hoplimit == 0) {
 		struct net_device *dev = dst->dev;
 		struct inet6_dev *idev;
 
@@ -1310,8 +1310,6 @@ install_route:
 		}
 	}
 
-	if (dst_metric_raw(&rt->dst, RTAX_HOPLIMIT) == 0)
-		dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	if (!dst_mtu(&rt->dst))
 		dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(dev));
 	if (!dst_metric(&rt->dst, RTAX_ADVMSS))
-- 
1.7.3.2

