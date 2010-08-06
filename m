From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] netem: dump distribution table
Date: Fri, 06 Aug 2010 12:35:55 -0700
Message-ID: <20100806193559.108503444@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35716 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761958Ab0HFTiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:05 -0400
Content-Disposition: inline; filename=netem-dump-dist.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing netem API is not symmetric; the current distribution
table is not added to dump output.  Since distribution table is 
could be large, only add it if there space available (for compatiablity
with older applications).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_netem.c	2010-08-03 08:29:43.926514463 -0700
+++ b/net/sched/sch_netem.c	2010-08-03 08:30:49.297380886 -0700
@@ -592,6 +592,13 @@ static int netem_dump(struct Qdisc *sch,
 	corrupt.correlation = q->corrupt_cor.rho;
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
+	/* dump table if exists and there is space available */
+	if (q->delay_dist) {
+		const struct disttable *d = q->delay_dist;
+		nla_put(skb, TCA_NETEM_DELAY_DIST,
+			d->size * sizeof(__s16), d->table);
+	}
+
 	return nla_nest_end(skb, nla);
 
 nla_put_failure:


