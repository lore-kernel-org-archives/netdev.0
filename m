From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/11] gen_stats.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:26 -0700
Message-ID: <de7ed4476339ad4dd67f56064fddc50bbeee410c.1379701322.git.joe@perches.com>
References: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/gen_stats.h | 51 ++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 26 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index cf8439b..ea4271d 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -19,32 +19,31 @@ struct gnet_dump {
 	struct tc_stats   tc_stats;
 };
 
-extern int gnet_stats_start_copy(struct sk_buff *skb, int type,
+int gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
+			  struct gnet_dump *d);
+
+int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
+				 int tc_stats_type, int xstats_type,
 				 spinlock_t *lock, struct gnet_dump *d);
 
-extern int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
-					int tc_stats_type,int xstats_type,
-					spinlock_t *lock, struct gnet_dump *d);
-
-extern int gnet_stats_copy_basic(struct gnet_dump *d,
-				 struct gnet_stats_basic_packed *b);
-extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
-				    const struct gnet_stats_basic_packed *b,
-				    struct gnet_stats_rate_est64 *r);
-extern int gnet_stats_copy_queue(struct gnet_dump *d,
-				 struct gnet_stats_queue *q);
-extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
-
-extern int gnet_stats_finish_copy(struct gnet_dump *d);
-
-extern int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
-			     struct gnet_stats_rate_est64 *rate_est,
-			     spinlock_t *stats_lock, struct nlattr *opt);
-extern void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
-			       struct gnet_stats_rate_est64 *rate_est);
-extern int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
-				 struct gnet_stats_rate_est64 *rate_est,
-				 spinlock_t *stats_lock, struct nlattr *opt);
-extern bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
-				 const struct gnet_stats_rate_est64 *rate_est);
+int gnet_stats_copy_basic(struct gnet_dump *d,
+			  struct gnet_stats_basic_packed *b);
+int gnet_stats_copy_rate_est(struct gnet_dump *d,
+			     const struct gnet_stats_basic_packed *b,
+			     struct gnet_stats_rate_est64 *r);
+int gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q);
+int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
+
+int gnet_stats_finish_copy(struct gnet_dump *d);
+
+int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
+		      struct gnet_stats_rate_est64 *rate_est,
+		      spinlock_t *stats_lock, struct nlattr *opt);
+void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
+			struct gnet_stats_rate_est64 *rate_est);
+int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
+			  struct gnet_stats_rate_est64 *rate_est,
+			  spinlock_t *stats_lock, struct nlattr *opt);
+bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
+			  const struct gnet_stats_rate_est64 *rate_est);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
