From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) delay scheduler enqueue always succeeds.
Date: Thu, 17 Jun 2004 15:57:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617155735.0edc56ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If underlying fifo enqueue fails, return the status not 0.
Same patch should apply to both 2.6 and 2.4

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- a/net/sched/sch_delay.c	2004-06-17 15:13:15 -07:00
+++ b/net/sched/sch_delay.c	2004-06-17 15:13:15 -07:00
@@ -69,7 +69,7 @@
 		sch->stats.bytes += skb->len;
 		sch->stats.packets++;
 	}
-	return 0;
+	return ret;
 }
 
 /* Requeue packets but don't change time stamp */
