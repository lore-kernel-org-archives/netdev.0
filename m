From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] openvswitch: rename ->sync to ->syncp
Date: Fri, 14 Feb 2014 15:10:46 -0800
Message-ID: <1392419446-4559-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42570 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbaBNXKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 18:10:53 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so12815013pab.21
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 15:10:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Openvswitch defines u64_stats_sync as ->sync rather than ->syncp,
so fails to compile with netdev_alloc_pcpu_stats(). So just rename it to ->syncp.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 1c213bd24ad04f4430031 (net: introduce netdev_alloc_pcpu_stats() for drivers)
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 3a95406..36f8872c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -256,10 +256,10 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 
 out:
 	/* Update datapath statistics. */
-	u64_stats_update_begin(&stats->sync);
+	u64_stats_update_begin(&stats->syncp);
 	(*stats_counter)++;
 	stats->n_mask_hit += n_mask_hit;
-	u64_stats_update_end(&stats->sync);
+	u64_stats_update_end(&stats->syncp);
 }
 
 static struct genl_family dp_packet_genl_family = {
@@ -295,9 +295,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 err:
 	stats = this_cpu_ptr(dp->stats_percpu);
 
-	u64_stats_update_begin(&stats->sync);
+	u64_stats_update_begin(&stats->syncp);
 	stats->n_lost++;
-	u64_stats_update_end(&stats->sync);
+	u64_stats_update_end(&stats->syncp);
 
 	return err;
 }
@@ -606,9 +606,9 @@ static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
 		percpu_stats = per_cpu_ptr(dp->stats_percpu, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&percpu_stats->sync);
+			start = u64_stats_fetch_begin_bh(&percpu_stats->syncp);
 			local_stats = *percpu_stats;
-		} while (u64_stats_fetch_retry_bh(&percpu_stats->sync, start));
+		} while (u64_stats_fetch_retry_bh(&percpu_stats->syncp, start));
 
 		stats->n_hit += local_stats.n_hit;
 		stats->n_missed += local_stats.n_missed;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 6be9fbb..0531738 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -55,7 +55,7 @@ struct dp_stats_percpu {
 	u64 n_missed;
 	u64 n_lost;
 	u64 n_mask_hit;
-	struct u64_stats_sync sync;
+	struct u64_stats_sync syncp;
 };
 
 /**
