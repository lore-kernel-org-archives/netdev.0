From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 5/5] skbuff: remove tc_verd member
Date: Mon,  4 May 2015 20:48:38 +0200
Message-ID: <1430765318-13788-6-git-send-email-fw@strlen.de>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46879 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752000AbbEDSs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:59 -0400
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

not used anymore; replaced with tc_nocls and tc_{at,from}_ingress flags.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ifb.c                    | 1 -
 drivers/staging/octeon/ethernet-tx.c | 1 -
 include/linux/skbuff.h               | 4 ----
 net/core/dev.c                       | 1 -
 net/core/skbuff.c                    | 3 ---
 5 files changed, 10 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 5ec6797..9f88ac5 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -79,7 +79,6 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	while ((skb = __skb_dequeue(&dp->tq)) != NULL) {
-		skb->tc_verd = 0;
 		skb->tc_nocls = 1;
 
 		u64_stats_update_begin(&dp->tsync);
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 2852d8a..bac1685 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -406,7 +406,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb->tc_nocls = 0;
 	skb->tc_from_ingress = 0;
 	skb->tc_at_ingress = 0;
-	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
 #endif /* REUSE_SKBUFFS_WITHOUT_FREE */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d794077..eebbb79 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -483,7 +483,6 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
- *	@tc_verd: traffic control verdict
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
@@ -627,9 +626,6 @@ struct sk_buff {
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
-#ifdef CONFIG_NET_CLS_ACT
-	__u16			tc_verd;	/* traffic control verdict */
-#endif
 #endif
 
 	union {
diff --git a/net/core/dev.c b/net/core/dev.c
index e2549fd..7178602 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3702,7 +3702,6 @@ skip_taps:
 			goto unlock;
 	}
 
-	skb->tc_verd = 0;
 ncls:
 #endif
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..81dd87f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -848,9 +848,6 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #ifdef CONFIG_NET_SCHED
 	CHECK_SKB_FIELD(tc_index);
-#ifdef CONFIG_NET_CLS_ACT
-	CHECK_SKB_FIELD(tc_verd);
-#endif
 #endif
 
 }
-- 
2.0.5
