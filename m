From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 12/16] HTB: Remove unneeded rate estimator bits
Date: Thu, 21 Oct 2004 14:47:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124723.GQ21977@postel.suug.ch>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removes old generic unused rate estimator bits. HTB has its own
rate estimator routines and therefore no rate estimator is created
so there is no need to try and delete one. We might want to convert
it to the generic rate estimator at a later point.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_htb.c	2004-10-21 13:08:24.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_htb.c	2004-10-21 13:08:54.000000000 +0200
@@ -145,7 +145,6 @@
     struct gnet_stats_basic bstats;
     struct gnet_stats_queue qstats;
     struct gnet_stats_rate_est rate_est;
-    spinlock_t		*stats_lock;
     struct tc_htb_xstats xstats;/* our special stats */
     int refcnt;			/* usage count of this class */
 
@@ -1468,9 +1467,6 @@
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 	
-#ifdef CONFIG_NET_ESTIMATOR
-	qdisc_kill_estimator(&cl->stats);
-#endif
 	htb_destroy_filters (&cl->filter_list);
 	
 	while (!list_empty(&cl->children)) 
