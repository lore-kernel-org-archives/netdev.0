From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] dsmark:  checkpatch warning cleanup
Date: Sun, 20 Jan 2008 13:25:36 -0800
Message-ID: <20080120132536.6f29edda@deepthought>
References: <20080120131008.2039a35d@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38671 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755060AbYATVaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 16:30:30 -0500
In-Reply-To: <20080120131008.2039a35d@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of all style things checkpatch warns about, indentation
and whitespace.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_dsmark.c	2008-01-20 13:23:34.000000000 -0800
+++ b/net/sched/sch_dsmark.c	2008-01-20 13:24:45.000000000 -0800
@@ -152,7 +152,7 @@ static int dsmark_delete(struct Qdisc *s
 	return 0;
 }
 
-static void dsmark_walk(struct Qdisc *sch,struct qdisc_walker *walker)
+static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int i;
@@ -176,7 +176,8 @@ ignore:
 	}
 }
 
-static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,unsigned long cl)
+static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,
+						 unsigned long cl)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	return &p->filter_list;
@@ -184,7 +185,7 @@ static inline struct tcf_proto **dsmark_
 
 /* --------------------------- Qdisc operations ---------------------------- */
 
-static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
+static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
@@ -193,24 +194,24 @@ static int dsmark_enqueue(struct sk_buff
 
 	if (p->set_tc_index) {
 		switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
-				if (skb_cow_head(skb, sizeof(struct iphdr)))
-					goto drop;
+		case __constant_htons(ETH_P_IP):
+			if (skb_cow_head(skb, sizeof(struct iphdr)))
+				goto drop;
 
-				skb->tc_index = ipv4_get_dsfield(ip_hdr(skb))
-					& ~INET_ECN_MASK;
-				break;
+			skb->tc_index = ipv4_get_dsfield(ip_hdr(skb))
+				& ~INET_ECN_MASK;
+			break;
 
-			case __constant_htons(ETH_P_IPV6):
-				if (skb_cow_head(skb, sizeof(struct ipv6hdr)))
-					goto drop;
+		case __constant_htons(ETH_P_IPV6):
+			if (skb_cow_head(skb, sizeof(struct ipv6hdr)))
+				goto drop;
 
-				skb->tc_index = ipv6_get_dsfield(ipv6_hdr(skb))
-					& ~INET_ECN_MASK;
-				break;
-			default:
-				skb->tc_index = 0;
-				break;
+			skb->tc_index = ipv6_get_dsfield(ipv6_hdr(skb))
+				& ~INET_ECN_MASK;
+			break;
+		default:
+			skb->tc_index = 0;
+			break;
 		}
 	}
 
@@ -243,7 +244,7 @@ static int dsmark_enqueue(struct sk_buff
 		}
 	}
 
-	err = p->q->enqueue(skb,p->q);
+	err = p->q->enqueue(skb, p->q);
 	if (err != NET_XMIT_SUCCESS) {
 		sch->qstats.drops++;
 		return err;
@@ -279,31 +280,31 @@ static struct sk_buff *dsmark_dequeue(st
 	pr_debug("index %d->%d\n", skb->tc_index, index);
 
 	switch (skb->protocol) {
-		case __constant_htons(ETH_P_IP):
-			ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
-					    p->value[index]);
+	case __constant_htons(ETH_P_IP):
+		ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
+				    p->value[index]);
 			break;
-		case __constant_htons(ETH_P_IPV6):
-			ipv6_change_dsfield(ipv6_hdr(skb), p->mask[index],
-					    p->value[index]);
-			break;
-		default:
-			/*
-			 * Only complain if a change was actually attempted.
-			 * This way, we can send non-IP traffic through dsmark
-			 * and don't need yet another qdisc as a bypass.
-			 */
-			if (p->mask[index] != 0xff || p->value[index])
-				printk(KERN_WARNING "dsmark_dequeue: "
-				       "unsupported protocol %d\n",
-				       ntohs(skb->protocol));
+	case __constant_htons(ETH_P_IPV6):
+		ipv6_change_dsfield(ipv6_hdr(skb), p->mask[index],
+				    p->value[index]);
 			break;
+	default:
+		/*
+		 * Only complain if a change was actually attempted.
+		 * This way, we can send non-IP traffic through dsmark
+		 * and don't need yet another qdisc as a bypass.
+		 */
+		if (p->mask[index] != 0xff || p->value[index])
+			printk(KERN_WARNING
+			       "dsmark_dequeue: unsupported protocol %d\n",
+			       ntohs(skb->protocol));
+		break;
 	}
 
 	return skb;
 }
 
-static int dsmark_requeue(struct sk_buff *skb,struct Qdisc *sch)
+static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
@@ -423,8 +424,8 @@ static int dsmark_dump_class(struct Qdis
 	tcm->tcm_info = p->q->handle;
 
 	opts = RTA_NEST(skb, TCA_OPTIONS);
-	RTA_PUT_U8(skb,TCA_DSMARK_MASK, p->mask[cl-1]);
-	RTA_PUT_U8(skb,TCA_DSMARK_VALUE, p->value[cl-1]);
+	RTA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl-1]);
+	RTA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl-1]);
 
 	return RTA_NEST_END(skb, opts);
 
