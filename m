From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) packet scheduler exports
Date: Tue, 29 Jun 2004 14:00:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629140014.1aba3719@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The packet scheduling code has some ugly define's which were to deal with
configuration possibilities and the old style module exports.  With the current
2.6 method, this is unnecessary.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-06-29 11:32:21 -07:00
+++ b/include/net/pkt_sched.h	2004-06-29 11:32:21 -07:00
@@ -210,12 +210,8 @@
 #define PSCHED_US2JIFFIE(usecs) (((usecs)+(1000000/HZ-1))/(1000000/HZ))
 #define PSCHED_JIFFIE2US(delay) ((delay)*(1000000/HZ))
 
-#define PSCHED_EXPORTLIST EXPORT_SYMBOL(psched_tod_diff);
-
 #else /* PSCHED_CLOCK_SOURCE != PSCHED_GETTIMEOFDAY */
 
-#define PSCHED_EXPORTLIST PSCHED_EXPORTLIST_1 PSCHED_EXPORTLIST_2
-
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
@@ -235,8 +231,6 @@
 #define PSCHED_JSCALE 10
 #endif
 
-#define PSCHED_EXPORTLIST_2
-
 #if BITS_PER_LONG <= 32
 
 #define PSCHED_WATCHER unsigned long
@@ -245,15 +239,10 @@
 
 #define PSCHED_GET_TIME(stamp) ((stamp) = psched_time_base + (((unsigned long)(jiffies-psched_time_mark))<<PSCHED_JSCALE))
 
-#define PSCHED_EXPORTLIST_1 EXPORT_SYMBOL(psched_time_base); \
-                            EXPORT_SYMBOL(psched_time_mark);
-
 #else
 
 #define PSCHED_GET_TIME(stamp) ((stamp) = (jiffies<<PSCHED_JSCALE))
 
-#define PSCHED_EXPORTLIST_1 
-
 #endif
 
 #define PSCHED_US2JIFFIE(delay) (((delay)+(1<<PSCHED_JSCALE)-1)>>PSCHED_JSCALE)
@@ -264,9 +253,6 @@
 extern psched_tdiff_t psched_clock_per_hz;
 extern int psched_clock_scale;
 
-#define PSCHED_EXPORTLIST_2 EXPORT_SYMBOL(psched_clock_per_hz); \
-                            EXPORT_SYMBOL(psched_clock_scale);
-
 #define PSCHED_US2JIFFIE(delay) (((delay)+psched_clock_per_hz-1)/psched_clock_per_hz)
 #define PSCHED_JIFFIE2US(delay) ((delay)*psched_clock_per_hz)
 
@@ -278,8 +264,6 @@
    (stamp) = __cur>>psched_clock_scale; \
 })
 
-#define PSCHED_EXPORTLIST_1
-
 #elif defined (__alpha__)
 
 #define PSCHED_WATCHER u32
@@ -293,9 +277,6 @@
    psched_time_mark = __res; \
    (stamp) = (psched_time_base + __res)>>psched_clock_scale; \
 })
-
-#define PSCHED_EXPORTLIST_1 EXPORT_SYMBOL(psched_time_base); \
-                            EXPORT_SYMBOL(psched_time_mark);
 
 #else
 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-06-29 11:32:21 -07:00
+++ b/net/sched/sch_api.c	2004-06-29 11:32:21 -07:00
@@ -1098,6 +1098,7 @@
 		delta = bound;
 	return delta;
 }
+EXPORT_SYMBOL(psched_tod_diff);
 #endif
 
 psched_time_t psched_time_base;
@@ -1105,10 +1106,14 @@
 #if PSCHED_CLOCK_SOURCE == PSCHED_CPU
 psched_tdiff_t psched_clock_per_hz;
 int psched_clock_scale;
+EXPORT_SYMBOL(psched_clock_per_hz);
+EXPORT_SYMBOL(psched_clock_scale);
 #endif
 
 #ifdef PSCHED_WATCHER
 PSCHED_WATCHER psched_time_mark;
+EXPORT_SYMBOL(psched_time_mark);
+EXPORT_SYMBOL(psched_time_base);
 
 static void psched_tick(unsigned long);
 
@@ -1214,4 +1219,3 @@
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
 EXPORT_SYMBOL(unregister_qdisc);
-PSCHED_EXPORTLIST;
