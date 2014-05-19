From: <rongqing.li@windriver.com>
Subject: [PATCH net-next] ipv6: slight optimization in ip6_dst_gc
Date: Mon, 19 May 2014 17:30:28 +0800
Message-ID: <1400491828-14335-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61489 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaESJaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 05:30:30 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
	by mail.windriver.com (8.14.5/8.14.5) with ESMTP id s4J9UToW001211
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 May 2014 02:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

entries is always greater than rt_max_size here, since if entries is less
than rt_max_size, the fib6_run_gc function will be skipped

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f0a8ff9..aa883af 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1455,7 +1455,7 @@ static int ip6_dst_gc(struct dst_ops *ops)
 		goto out;
 
 	net->ipv6.ip6_rt_gc_expire++;
-	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net, entries > rt_max_size);
+	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net, true);
 	entries = dst_entries_get_slow(ops);
 	if (entries < ops->gc_thresh)
 		net->ipv6.ip6_rt_gc_expire = rt_gc_timeout>>1;
-- 
1.7.10.4
