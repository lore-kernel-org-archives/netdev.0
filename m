From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/6] [PATCH 5/9] netem: cleanup dump code
Date: Wed, 23 Feb 2011 15:04:17 -0800
Message-ID: <20110223230534.078421197@vyatta.com>
References: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47469 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754649Ab1BWXHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:49 -0500
Content-Disposition: inline; filename=netem-dump.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use nla_put_nested to update netlink attribute value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/sched/sch_netem.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

--- a/net/sched/sch_netem.c	2011-02-23 14:43:09.114302606 -0800
+++ b/net/sched/sch_netem.c	2011-02-23 14:43:27.598650361 -0800
@@ -562,8 +562,7 @@ static void netem_destroy(struct Qdisc *
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	const struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla = (struct nlattr *) b;
+	struct nlattr *nla = (struct nlattr *) skb_tail_pointer(skb);
 	struct tc_netem_qopt qopt;
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
@@ -590,12 +589,10 @@ static int netem_dump(struct Qdisc *sch,
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
 


