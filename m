From: Masashi Honma <masashi.honma@gmail.com>
Subject: [PATCH] ipv6 route: Aggregate table getting code
Date: Sun, 18 Oct 2015 09:51:39 +0900
Message-ID: <1445129499-2496-1-git-send-email-masashi.honma@gmail.com>
Cc: Masashi Honma <masashi.honma@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36804 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbJRAvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 20:51:52 -0400
Received: by pacfv9 with SMTP id fv9so57426678pac.3
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 17:51:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These lines could be aggregated to one line because fib6_new_table() calls
fib6_get_table() inside on both cases CONFIG_IPV6_MULTIPLE_TABLES is enabled or
not.

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 net/ipv6/route.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb32ce2..1ff4130 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1778,16 +1778,7 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
 	err = -ENOBUFS;
-	if (cfg->fc_nlinfo.nlh &&
-	    !(cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_CREATE)) {
-		table = fib6_get_table(net, cfg->fc_table);
-		if (!table) {
-			pr_warn("NLM_F_CREATE should be specified when creating new route\n");
-			table = fib6_new_table(net, cfg->fc_table);
-		}
-	} else {
-		table = fib6_new_table(net, cfg->fc_table);
-	}
+	table = fib6_new_table(net, cfg->fc_table);
 
 	if (!table)
 		goto out;
-- 
1.9.1
