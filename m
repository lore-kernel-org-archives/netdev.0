From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/8] pedit: use gnet_stats for action stats
Date: Wed, 3 Nov 2004 23:01:33 +0100
Message-ID: <20041103220133.GF12289@postel.suug.ch>
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

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/pedit.c linux-2.6.10-rc1-bk11/net/sched/pedit.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/pedit.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/pedit.c	2004-11-02 12:11:11.000000000 +0100
@@ -183,10 +183,10 @@
 	}
 
 bad:
-	p->stats.overlimits++;
+	p->qstats.overlimits++;
 done:
-	p->stats.bytes += skb->len;
-	p->stats.packets++;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
 	spin_unlock(&p->lock);
 	return p->action;
 }
@@ -255,17 +255,6 @@
 	return -1;
 }
 
-int
-tcf_pedit_stats(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_pedit *p;
-	p = PRIV(a,pedit);
-	if (NULL != p)
-		return qdisc_copy_stats(skb, &p->stats, p->stats_lock);
-
-	return 1;
-}
-
 static
 struct tc_action_ops act_pedit_ops = {
 	.kind		=	"pedit",
@@ -273,7 +262,6 @@
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_pedit,
-	.get_stats	=	tcf_pedit_stats,
 	.dump		=	tcf_pedit_dump,
 	.cleanup	=	tcf_pedit_cleanup,
 	.lookup		=	tcf_hash_search,
