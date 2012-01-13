From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: release idev when ip6_neigh_lookup failed in icmp6_dst_alloc
Date: Fri, 13 Jan 2012 16:33:46 +0800
Message-ID: <1326443626-19580-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57633 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab2AMIeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:34:00 -0500
Received: by wgbds12 with SMTP id ds12so2796476wgb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 00:33:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

release idev when ip6_neigh_lookup failed in icmp6_dst_alloc

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 07361df..8c2e3ab 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1091,6 +1091,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	else {
 		neigh = ip6_neigh_lookup(&rt->dst, &fl6->daddr);
 		if (IS_ERR(neigh)) {
+			in6_dev_put(idev);
 			dst_free(&rt->dst);
 			return ERR_CAST(neigh);
 		}
-- 
1.7.1
