From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v2 2/2] ipv6:  Warn users if maximum number of routes is reached.
Date: Mon,  8 Nov 2010 14:33:48 -0800
Message-ID: <1289255628-9596-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48648 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab0KHWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gives users at least some clue as to what the problem
might be and how to go about fixing it.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v1 -> v2:  Put warning in correct place.

:100644 100644 a275c6e... 9d9d0e9... M	net/ipv6/route.c
 net/ipv6/route.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a275c6e..9d9d0e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1941,8 +1941,12 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
 	struct neighbour *neigh;
 
-	if (rt == NULL)
+	if (rt == NULL) {
+		if (net_ratelimit())
+			pr_warning("IPv6:  Maximum number of routes reached,"
+				   " consider increasing route/max_size.\n");
 		return ERR_PTR(-ENOMEM);
+	}
 
 	dev_hold(net->loopback_dev);
 	in6_dev_hold(idev);
-- 
1.6.2.5

