From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] pkt_sched: sch_generic: Kfree gso_skb in
	qdisc_reset()
Date: Mon, 3 Nov 2008 09:02:25 +0000
Message-ID: <20081103090225.GB4698@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:43213 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779AbYKCJCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 04:02:31 -0500
Received: by nf-out-0910.google.com with SMTP id d3so911960nfc.21
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 01:02:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: sch_generic: Kfree gso_skb in qdisc_reset()

Since gso_skb is re-used for qdisc_peek_dequeued(), and this skb is
counted in the qdisc->q.qlen, it has to be kfreed during qdisc_reset()
when qlen is zeroed.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 318c9f6..cdf064b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -542,6 +542,8 @@ void qdisc_reset(struct Qdisc *qdisc)
 
 	if (ops->reset)
 		ops->reset(qdisc);
+
+	kfree_skb(qdisc->gso_skb);
 }
 EXPORT_SYMBOL(qdisc_reset);
 
