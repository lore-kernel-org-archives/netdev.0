From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] ip6_gre: use netdev_alloc_pcpu_stats()
Date: Wed, 22 Apr 2015 16:56:16 +0200
Message-ID: <1429714576-23911-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55142 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932874AbbDVO4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 10:56:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The code there just open-codes the same, so use the provided macro instead.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/ipv6/ip6_gre.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index b5e6cc1d4a73..a38d3ac0f18f 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1246,7 +1246,6 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 static int ip6gre_tunnel_init(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
-	int i;
 
 	tunnel = netdev_priv(dev);
 
@@ -1260,16 +1259,10 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	if (ipv6_addr_any(&tunnel->parms.raddr))
 		dev->header_ops = &ip6gre_header_ops;
 
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ip6gre_tunnel_stats;
-		ip6gre_tunnel_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ip6gre_tunnel_stats->syncp);
-	}
-
 	return 0;
 }
 
-- 
2.1.4
