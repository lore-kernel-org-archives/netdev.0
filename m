From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: sch_generic: Kfree gso_skb in
	qdisc_reset()
Date: Mon, 3 Nov 2008 09:48:30 +0000
Message-ID: <20081103094830.GA6030@ff.dom.local>
References: <20081103090225.GB4698@ff.dom.local> <20081103.012755.210488675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:43450 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbYKCJsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 04:48:38 -0500
Received: by nf-out-0910.google.com with SMTP id d3so917705nfc.21
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 01:48:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081103.012755.210488675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 01:27:55AM -0800, David Miller wrote:
...
> Isn't it necessary, or at least more tidy, to NULL out
> this value too?

Sure it is!

Thanks!
Jarek P.
-----------------------> take 2

pkt_sched: sch_generic: Kfree gso_skb in qdisc_reset()

Since gso_skb is re-used for qdisc_peek_dequeued(), and this skb is
counted in the qdisc->q.qlen, it has to be kfreed during qdisc_reset()
when qlen is zeroed.

With help from David S. Miller <davem@davemloft.net>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 318c9f6..1192da2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -542,6 +542,9 @@ void qdisc_reset(struct Qdisc *qdisc)
 
 	if (ops->reset)
 		ops->reset(qdisc);
+
+	kfree_skb(qdisc->gso_skb);
+	qdisc->gso_skb = NULL;
 }
 EXPORT_SYMBOL(qdisc_reset);
 
