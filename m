From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [NET]: Allow dumping of application specific statistics if no primary TLV is used
Date: Sat, 2 Apr 2005 01:28:01 +0200
Message-ID: <20050401232801.GL3086@postel.suug.ch>
References: <20050401232654.GJ3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050401232654.GJ3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/01 14:24:14+02:00 tgraf@suug.ch 
#   [NET]: Allow dumping of application specific statistics if no primary TLV is used
#   
#   Although this case is hypothetical at the moment, more advanced actions are
#   likely to need this in the future.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net> 
# 
# net/core/gen_stats.c
#   2005/04/01 14:23:57+02:00 tgraf@suug.ch +7 -4
#   [NET]: Allow dumping of application specific statistics if no primary TLV is used
# 
# include/net/gen_stats.h
#   2005/04/01 14:23:57+02:00 tgraf@suug.ch +2 -1
#   [NET]: Allow dumping of application specific statistics if no primary TLV is used
# 
diff -Nru a/include/net/gen_stats.h b/include/net/gen_stats.h
--- a/include/net/gen_stats.h	2005-04-02 01:18:33 +02:00
+++ b/include/net/gen_stats.h	2005-04-02 01:18:33 +02:00
@@ -15,7 +15,8 @@
 	/* Backward compatability */
 	int               compat_tc_stats;
 	int               compat_xstats;
-	struct rtattr *   xstats;
+	void *            xstats;
+	int               xstats_len;
 	struct tc_stats   tc_stats;
 };
 
diff -Nru a/net/core/gen_stats.c b/net/core/gen_stats.c
--- a/net/core/gen_stats.c	2005-04-02 01:18:33 +02:00
+++ b/net/core/gen_stats.c	2005-04-02 01:18:33 +02:00
@@ -177,8 +177,11 @@
 int
 gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 {
-	if (d->compat_xstats)
-		d->xstats = (struct rtattr *) d->skb->tail;
+	if (d->compat_xstats) {
+		d->xstats = st;
+		d->xstats_len = len;
+	}
+
 	return gnet_stats_copy(d, TCA_STATS_APP, st, len);
 }
 
@@ -206,8 +209,8 @@
 			return -1;
 
 	if (d->compat_xstats && d->xstats) {
-		if (gnet_stats_copy(d, d->compat_xstats, RTA_DATA(d->xstats),
-			RTA_PAYLOAD(d->xstats)) < 0)
+		if (gnet_stats_copy(d, d->compat_xstats, d->xstats,
+			d->xstats_len) < 0)
 			return -1;
 	}
 
