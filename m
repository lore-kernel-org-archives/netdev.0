From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) delay scheduler enqueue always succeeds.
Date: Thu, 17 Jun 2004 15:55:56 -0700
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <20040617155556.5f53dff0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: "David S. Miller" <davem@redhat.com>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
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
_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
