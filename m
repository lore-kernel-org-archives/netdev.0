From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] ipv4: fib: Remove unused functions
Date: Wed,  2 Aug 2017 09:56:06 +0200
Message-ID: <20170802075606.1090-7-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36632 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdHBH4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:19 -0400
Received: by mail-wm0-f65.google.com with SMTP id d40so6141992wma.3
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:18 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previous patches converted users of these functions to provide offload
indication using the nexthop's flags instead of the FIB info's.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 41d580c..ef8992d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -124,7 +124,6 @@ struct fib_info {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_weight;
 #endif
-	unsigned int		fib_offload_cnt;
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
@@ -177,18 +176,6 @@ struct fib_result_nl {
 
 __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 
-static inline void fib_info_offload_inc(struct fib_info *fi)
-{
-	fi->fib_offload_cnt++;
-	fi->fib_flags |= RTNH_F_OFFLOAD;
-}
-
-static inline void fib_info_offload_dec(struct fib_info *fi)
-{
-	if (--fi->fib_offload_cnt == 0)
-		fi->fib_flags &= ~RTNH_F_OFFLOAD;
-}
-
 #define FIB_RES_SADDR(net, res)				\
 	((FIB_RES_NH(res).nh_saddr_genid ==		\
 	  atomic_read(&(net)->ipv4.dev_addr_genid)) ?	\
-- 
2.9.3
