From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/8] gact: use gnet_stats for action stats
Date: Wed, 3 Nov 2004 22:59:48 +0100
Message-ID: <20041103215948.GC12289@postel.suug.ch>
References: <20041103215816.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103215816.GA12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/gact.c linux-2.6.10-rc1-bk11/net/sched/gact.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/gact.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/gact.c	2004-11-02 12:10:39.000000000 +0100
@@ -62,7 +62,7 @@
 
 int
 gact_determ(struct tcf_gact *p) {
-	if (p->stats.packets%p->pval)
+	if (p->bstats.packets%p->pval)
 		return p->action;
 	return p->paction;
 }
@@ -163,10 +163,10 @@
 #else
 	action = p->action;
 #endif
-	p->stats.bytes += skb->len;
-	p->stats.packets++;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
 	if (TC_ACT_SHOT == action)
-		p->stats.drops++;
+		p->qstats.drops++;
 	p->tm.lastuse = jiffies;
 	spin_unlock(&p->lock);
 
@@ -214,17 +214,6 @@
 	return -1;
 }
 
-int
-tcf_gact_stats(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_gact *p;
-	p = PRIV(a,gact);
-	if (NULL != p)
-		return qdisc_copy_stats(skb, &p->stats,p->stats_lock);
-
-	return 1;
-}
-
 struct tc_action_ops act_gact_ops = {
 	.next		=	NULL,
 	.kind		=	"gact",
@@ -232,7 +221,6 @@
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_gact,
-	.get_stats	=	tcf_gact_stats,
 	.dump		=	tcf_gact_dump,
 	.cleanup	=	tcf_gact_cleanup,
 	.lookup		=	tcf_hash_search,
