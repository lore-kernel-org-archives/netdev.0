From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) netetm: trap infinite loop hange on qlen underflow
Date: Tue, 3 May 2005 16:27:18 -0700
Message-ID: <20050503162718.6a670800@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Due to bugs in netem (fixed by later patches), it is possible to get qdisc
qlen to go negative. If this happens the CPU ends up spinning forever
in qdisc_run(). So add a BUG_ON() to trap it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: netem-2.6.12-rc3/net/sched/sch_generic.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_generic.c	2005-05-03 10:55:50.000000000 -0700
+++ netem-2.6.12-rc3/net/sched/sch_generic.c	2005-05-03 10:56:01.000000000 -0700
@@ -179,6 +179,7 @@
 		netif_schedule(dev);
 		return 1;
 	}
+	BUG_ON((int) q->q.qlen < 0);
 	return q->q.qlen;
 }
 
