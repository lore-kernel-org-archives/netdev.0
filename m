From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] netem: cleanup dump code
Date: Fri, 06 Aug 2010 12:35:53 -0700
Message-ID: <20100806193558.931255425@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35714 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab0HFTiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:04 -0400
Content-Disposition: inline; filename=netem-dump.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use nla_put_nested to update netlink attribute value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_netem.c	2010-08-03 08:28:28.031830483 -0700
+++ b/net/sched/sch_netem.c	2010-08-03 08:29:39.546593787 -0700
@@ -565,8 +565,7 @@ static void netem_destroy(struct Qdisc *
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	const struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla = (struct nlattr *) b;
+	struct nlattr *nla = (struct nlattr *) skb_tail_pointer(skb);
 	struct tc_netem_qopt qopt;
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
@@ -593,12 +592,10 @@ static int netem_dump(struct Qdisc *sch,
 	corrupt.correlation = q->corrupt_cor.rho;
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
-
-	return skb->len;
+	return nla_nest_end(skb, nla);
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nlmsg_trim(skb, nla);
 	return -1;
 }
 


