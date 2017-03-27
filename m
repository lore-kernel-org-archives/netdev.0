From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/5] rds: remove unnecessary returned value check
Date: Mon, 27 Mar 2017 03:06:28 -0400
Message-ID: <1490598390-13812-4-git-send-email-yanjun.zhu@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490598390-13812-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the function rds_stats_init, the returned value
is always zero. As such, it is not necessary to check it.
And change the return type to void.

Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/af_rds.c | 5 +----
 net/rds/rds.h    | 2 +-
 net/rds/stats.c  | 3 +--
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index b405f77..a696096 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -658,9 +658,7 @@ static int rds_init(void)
 	ret = rds_sysctl_init();
 	if (ret)
 		goto out_threads;
-	ret = rds_stats_init();
-	if (ret)
-		goto out_sysctl;
+	rds_stats_init();
 	ret = proto_register(&rds_proto, 1);
 	if (ret)
 		goto out_stats;
@@ -677,7 +675,6 @@ static int rds_init(void)
 	proto_unregister(&rds_proto);
 out_stats:
 	rds_stats_exit();
-out_sysctl:
 	rds_sysctl_exit();
 out_threads:
 	rds_threads_exit();
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 82d38cc..82a8856 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -870,7 +870,7 @@ DECLARE_PER_CPU_SHARED_ALIGNED(struct rds_statistics, rds_stats);
 	put_cpu();					\
 } while (0)
 #define rds_stats_add(member, count) rds_stats_add_which(rds_stats, member, count)
-int rds_stats_init(void);
+void rds_stats_init(void);
 void rds_stats_exit(void);
 void rds_stats_info_copy(struct rds_info_iterator *iter,
 			 uint64_t *values, const char *const *names,
diff --git a/net/rds/stats.c b/net/rds/stats.c
index 73be187..e83b4bb 100644
--- a/net/rds/stats.c
+++ b/net/rds/stats.c
@@ -145,8 +145,7 @@ void rds_stats_exit(void)
 	rds_info_deregister_func(RDS_INFO_COUNTERS, rds_stats_info);
 }
 
-int rds_stats_init(void)
+void rds_stats_init(void)
 {
 	rds_info_register_func(RDS_INFO_COUNTERS, rds_stats_info);
-	return 0;
 }
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
