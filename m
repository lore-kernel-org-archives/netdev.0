From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] PKT_SCHED: Introduce gen_replace_estimator
Date: Thu, 7 Oct 2004 03:05:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010541.GD18621@postel.suug.ch>
References: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007010146.GA18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduces gen_replace_estimator.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.9-rc3-bk6.orig/include/net/gen_stats.h linux-2.6.9-rc3-bk6/include/net/gen_stats.h
--- linux-2.6.9-rc3-bk6.orig/include/net/gen_stats.h	2004-10-06 14:19:13.000000000 +0200
+++ linux-2.6.9-rc3-bk6/include/net/gen_stats.h	2004-10-06 20:34:13.000000000 +0200
@@ -41,5 +41,8 @@
 			     spinlock_t *stats_lock, struct rtattr *opt);
 extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
 			       struct gnet_stats_rate_est *rate_est);
+extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
+				 struct gnet_stats_rate_est *rate_est,
+				 spinlock_t *stats_lock, struct rtattr *opt);
 
 #endif
diff -Nru linux-2.6.9-rc3-bk6.orig/net/core/gen_estimator.c linux-2.6.9-rc3-bk6/net/core/gen_estimator.c
--- linux-2.6.9-rc3-bk6.orig/net/core/gen_estimator.c	2004-10-06 14:19:46.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/core/gen_estimator.c	2004-10-06 20:33:43.000000000 +0200
@@ -200,5 +200,16 @@
 	}
 }
 
+int
+gen_replace_estimator(struct gnet_stats_basic *bstats,
+	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock,
+	struct rtattr *opt)
+{
+    gen_kill_estimator(bstats, rate_est);
+    return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+}
+    
+
 EXPORT_SYMBOL(gen_kill_estimator);
 EXPORT_SYMBOL(gen_new_estimator);
+EXPORT_SYMBOL(gen_replace_estimator);
