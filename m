From: kaber@trash.net
Subject: [PATCH 12/37] ipvs: remove unused seqcount stats
Date: Tue, 15 Mar 2011 20:43:52 +0100
Message-ID: <1300218257-26953-13-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49425 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758467Ab1COTo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:28 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	Remove ustats_seq, IPVS_STAT_INC and IPVS_STAT_ADD
because they are not used. They were replaced with u64_stats.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 06f5af4..cf014ab 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -377,22 +377,6 @@ struct ip_vs_stats {
 	struct ip_vs_stats_user	ustats0;	/* reset values */
 };
 
-/*
- * Helper Macros for per cpu
- * ipvs->tot_stats->ustats.count
- */
-#define IPVS_STAT_INC(ipvs, count)	\
-	__this_cpu_inc((ipvs)->ustats->count)
-
-#define IPVS_STAT_ADD(ipvs, count, value) \
-	do {\
-		write_seqcount_begin(per_cpu_ptr((ipvs)->ustats_seq, \
-				     raw_smp_processor_id())); \
-		__this_cpu_add((ipvs)->ustats->count, value); \
-		write_seqcount_end(per_cpu_ptr((ipvs)->ustats_seq, \
-				   raw_smp_processor_id())); \
-	} while (0)
-
 struct dst_entry;
 struct iphdr;
 struct ip_vs_conn;
@@ -853,7 +837,6 @@ struct netns_ipvs {
 
 	/* ip_vs_ctl */
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
-	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	int			num_services;    /* no of virtual services */
 	/* 1/rate drop and drop-entry variables */
-- 
1.7.2.3

