From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 10/11] PKT_SCHED: Inline psched_tod_diff
Date: Wed, 27 Oct 2004 00:28:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222854.GK12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_sched.h	2004-10-26 23:42:10.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_sched.h	2004-10-26 23:42:59.000000000 +0200
@@ -132,7 +132,18 @@
 	   __delta; \
 })
 
-extern int psched_tod_diff(int delta_sec, int bound);
+static inline int
+psched_tod_diff(int delta_sec, int bound)
+{
+	int delta;
+
+	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
+		return bound;
+	delta = delta_sec * 1000000;
+	if (delta > bound)
+		delta = bound;
+	return delta;
+}
 
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 ({ \
--- linux-2.6.10-rc1-bk1.orig/net/sched/sch_api.c	2004-10-26 23:37:57.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/sch_api.c	2004-10-26 23:44:05.000000000 +0200
@@ -1172,21 +1172,6 @@
 };	
 #endif
 
-#ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
-int psched_tod_diff(int delta_sec, int bound)
-{
-	int delta;
-
-	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
-		return bound;
-	delta = delta_sec * 1000000;
-	if (delta > bound)
-		delta = bound;
-	return delta;
-}
-EXPORT_SYMBOL(psched_tod_diff);
-#endif
-
 #ifdef CONFIG_NET_SCH_CLK_CPU
 psched_tdiff_t psched_clock_per_hz;
 int psched_clock_scale;
