From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/8] cls_*: use tcf_police_dump_stats to dump via new gnet_stats API
Date: Wed, 3 Nov 2004 23:03:11 +0100
Message-ID: <20041103220311.GI12289@postel.suug.ch>
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

diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/cls_fw.c linux-2.6.10-rc1-bk11/net/sched/cls_fw.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/cls_fw.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/cls_fw.c	2004-11-02 13:53:52.000000000 +0100
@@ -395,11 +395,9 @@
 	}
 #else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		if (qdisc_copy_stats(skb, &f->police->stats,
-			f->police->stats_lock))
+	if (f->police)
+		if (tcf_police_dump_stats(skb, f->police) < 0)
 			goto rtattr_failure;
-	}
 #endif /* CONFIG_NET_CLS_POLICE */
 #endif /* CONFIG_NET_CLS_ACT */
 	return skb->len;
diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/cls_route.c linux-2.6.10-rc1-bk11/net/sched/cls_route.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/cls_route.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/cls_route.c	2004-11-02 13:53:52.000000000 +0100
@@ -566,11 +566,9 @@
 
 	rta->rta_len = skb->tail - b;
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		if (qdisc_copy_stats(skb, &f->police->stats,
-				     f->police->stats_lock))
+	if (f->police)
+		if (tcf_police_dump_stats(skb, f->police) < 0)
 			goto rtattr_failure;
-	}
 #endif
 	return skb->len;
 
diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/cls_rsvp.h linux-2.6.10-rc1-bk11/net/sched/cls_rsvp.h
--- linux-2.6.10-rc1-bk11.orig/net/sched/cls_rsvp.h	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/cls_rsvp.h	2004-11-02 13:53:52.000000000 +0100
@@ -631,11 +631,9 @@
 
 	rta->rta_len = skb->tail - b;
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		if (qdisc_copy_stats(skb, &f->police->stats,
-				     f->police->stats_lock))
+	if (f->police)
+		if (tcf_police_dump_stats(skb, f->police) < 0)
 			goto rtattr_failure;
-	}
 #endif
 	return skb->len;
 
diff -Nru linux-2.6.10-rc1-bk11.orig/net/sched/cls_u32.c linux-2.6.10-rc1-bk11/net/sched/cls_u32.c
--- linux-2.6.10-rc1-bk11.orig/net/sched/cls_u32.c	2004-11-02 11:43:27.000000000 +0100
+++ linux-2.6.10-rc1-bk11/net/sched/cls_u32.c	2004-11-02 13:53:52.000000000 +0100
@@ -775,11 +775,9 @@
 	}
 #else
 #ifdef CONFIG_NET_CLS_POLICE
-	if (TC_U32_KEY(n->handle) && n->police) {
-		if (qdisc_copy_stats(skb, &n->police->stats,
-				     n->police->stats_lock))
+	if (TC_U32_KEY(n->handle) && n->police)
+		if (tcf_police_dump_stats(skb, n->police) < 0)
 			goto rtattr_failure;
-	}
 #endif
 #endif
 	return skb->len;
