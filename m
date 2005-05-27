From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/7] [PKT_SCHED] make dsmark try using pfifo instead of noop while grafting
Date: Fri, 27 May 2005 16:51:36 +0200
Message-ID: <20050527145136.GT15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 0297af53b691b2c14b09f65be7b9e32a43a34319
tree 686339fe0d5a70e263d261324365e65f53cc9880
parent 99ed2eb92cc035b223e2d383446f7f183600ba27
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:30:37 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:30:37 +0200

 net/sched/sch_dsmark.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- 127116412eeedf62fcda0acc882500cd981cbab1/net/sched/sch_dsmark.c  (mode:100644)
+++ 686339fe0d5a70e263d261324365e65f53cc9880/net/sched/sch_dsmark.c  (mode:100644)
@@ -73,8 +73,13 @@
 
 	DPRINTK("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",sch,p,new,
 	    old);
-	if (!new)
-		new = &noop_qdisc;
+
+	if (new == NULL) {
+		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+		if (new == NULL)
+			new = &noop_qdisc;
+	}
+
 	sch_tree_lock(sch);
 	*old = xchg(&p->q,new);
 	if (*old)
