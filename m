From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv4: remove fib_weight
Date: Wed, 27 Sep 2017 19:08:00 -0700
Message-ID: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33114 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752239AbdI1CIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 22:08:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so138608pfk.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 19:08:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_weight in fib_info is set but not used. Remove it and the
helpers for setting it.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h     | 3 ---
 net/ipv4/fib_semantics.c | 9 ---------
 2 files changed, 12 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 1a7f7e424320..f80524396c06 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -122,9 +122,6 @@ struct fib_info {
 #define fib_rtt fib_metrics->metrics[RTAX_RTT-1]
 #define fib_advmss fib_metrics->metrics[RTAX_ADVMSS-1]
 	int			fib_nhs;
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	int			fib_weight;
-#endif
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 57a5d48acee8..be0874620ecc 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -601,17 +601,9 @@ static void fib_rebalance(struct fib_info *fi)
 		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);
 	} endfor_nexthops(fi);
 }
-
-static inline void fib_add_weight(struct fib_info *fi,
-				  const struct fib_nh *nh)
-{
-	fi->fib_weight += nh->nh_weight;
-}
-
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
 
 #define fib_rebalance(fi) do { } while (0)
-#define fib_add_weight(fi, nh) do { } while (0)
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
@@ -1275,7 +1267,6 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
-		fib_add_weight(fi, nexthop_nh);
 	} endfor_nexthops(fi)
 
 	fib_rebalance(fi);
-- 
2.1.4
