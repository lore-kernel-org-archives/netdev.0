From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/8] mirred: use gnet_stats for action stats
Date: Wed, 3 Nov 2004 23:01:03 +0100
Message-ID: <20041103220103.GE12289@postel.suug.ch>
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

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/mirred.c linux-2.6.10-rc1-bk11/net/sched/mirred.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/mirred.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/mirred.c	2004-11-02 12:10:07.000000000 +0100
@@ -195,9 +195,9 @@
 bad_mirred:
 		if (NULL != skb2)
 			kfree_skb(skb2);
-		p->stats.overlimits++;
-		p->stats.bytes += skb->len;
-		p->stats.packets++;
+		p->qstats.overlimits++;
+		p->bstats.bytes += skb->len;
+		p->bstats.packets++;
 		spin_unlock(&p->lock);
 		/* should we be asking for packet to be dropped?
 		 * may make sense for redirect case only 
@@ -216,8 +216,8 @@
 		goto bad_mirred;
 	}
 
-	p->stats.bytes += skb2->len;
-	p->stats.packets++;
+	p->bstats.bytes += skb2->len;
+	p->bstats.packets++;
 	if ( !(at & AT_EGRESS)) {
 		if (p->ok_push) {
 			skb_push(skb2, skb2->dev->hard_header_len);
@@ -268,18 +268,6 @@
 	return -1;
 }
 
-int
-tcf_mirred_stats(struct sk_buff *skb, struct tc_action *a)
-{
-	struct tcf_mirred *p;
-	p = PRIV(a,mirred);
-
-	if (NULL != p)
-		return qdisc_copy_stats(skb, &p->stats, p->stats_lock);
-
-	return 1;
-}
-
 static struct tc_action_ops act_mirred_ops = {
 	.next		=	NULL,
 	.kind		=	"mirred",
@@ -287,7 +275,6 @@
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_mirred,
-	.get_stats	=	tcf_mirred_stats,
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_cleanup,
 	.lookup		=	tcf_hash_search,
