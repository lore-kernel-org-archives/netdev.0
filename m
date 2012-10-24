From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: Set default hoplimit as zero.
Date: Wed, 24 Oct 2012 14:01:18 +0800
Message-ID: <1351058478-29252-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:51622 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757644Ab2JXGBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 02:01:23 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so96944dak.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 23:01:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Commit a02e4b7dae4551(Demark default hoplimit as zero) only changes the
hoplimit checking condition and default value in ip6_dst_hoplimit, not
zeros all hoplimit default value.

Keep the zeroing ip6_template_metrics[RTAX_HOPLIMIT - 1] to force it as 
const, cause as a37e6e344910(net: force dst_default_metrics to const 
section)

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d1ddbc6..ba3c16e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -219,7 +219,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 };
 
 static const u32 ip6_template_metrics[RTAX_MAX] = {
-	[RTAX_HOPLIMIT - 1] = 255,
+	[RTAX_HOPLIMIT - 1] = 0,
 };
 
 static const struct rt6_info ip6_null_entry_template = {
@@ -1232,7 +1232,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
-	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
+	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 0);
 
 	spin_lock_bh(&icmp6_dst_lock);
 	rt->dst.next = icmp6_dst_gc_list;
-- 
1.7.4.1
