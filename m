From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] netem limit not returned correctly
Date: Tue, 3 Aug 2004 13:11:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803131111.6ce2c36c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor leftover from earlier code.  Netem scheduler is not reporting
correct limit (ie for 'tc qdisc ls') because it is returning devices limit
not it's own.

Should apply to 2.4 as well (with fuzz)

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-03 13:10:17 -07:00
+++ b/net/sched/sch_netem.c	2004-08-03 13:10:17 -07:00
@@ -825,7 +825,7 @@
 
 	qopt.latency = q->latency;
 	qopt.jitter = q->jitter;
-	qopt.limit = sch->dev->tx_queue_len;
+	qopt.limit = q->limit;
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
 
