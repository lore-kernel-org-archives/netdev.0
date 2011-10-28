From: Gao feng <omarapazanadi@gmail.com>
Subject: [PATCH] ipv6: fix route error binding peer in func icmp6_dst_alloc
Date: Fri, 28 Oct 2011 20:46:57 +0800
Message-ID: <1319806017-6131-1-git-send-email-omarapazanadi@gmail.com>
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	Gao feng <omarapazanadi@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54057 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241Ab1J1MrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 08:47:09 -0400
Received: by qabj40 with SMTP id j40so3614743qab.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 05:47:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in func icmp6_dst_alloc,dst_metric_set call ipv6_cow_metrics to set metric.
ipv6_cow_metrics may will call rt6_bind_peer to set rt6_info->rt6i_peer.
So,we should move ipv6_addr_copy before dst_metric_set to make sure rt6_bind_peer success.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fb545ed..57b82dc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1086,11 +1086,10 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
-	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
-
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
+	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 
 	spin_lock_bh(&icmp6_dst_lock);
 	rt->dst.next = icmp6_dst_gc_list;
-- 
1.7.5.4
