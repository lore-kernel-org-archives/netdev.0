From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: sch_sfq: revert "dump a real number of flows"
	patch
Date: Thu, 24 Jul 2008 10:53:52 +0000
Message-ID: <20080724105352.GB3946@ff.dom.local>
References: <200806282202.59581.denys@visp.net.lb> <20080629191113.GA8817@ami.dom.local> <20080723.213443.37820788.davem@davemloft.net> <48884133.8070301@trash.net> <20080724094908.GA3946@ff.dom.local> <488851FB.4080407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:21108 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbYGXKsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 06:48:46 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1044920nfc.21
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 03:48:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <488851FB.4080407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 11:57:15AM +0200, Patrick McHardy wrote:
...
> IIRC the ESFQ for SFQ patches even use
> "flows" in ->init, so it might make things a bit more ugly if we
> ever merge those patches.

This argument looks right to me.

David, please, apply this reverting patch.

Thanks,
Jarek P.

-------------------->

pkt_sched: sch_sfq: revert "dump a real number of flows" patch

Patrick McHardy <kaber@trash.net> noticed that since "flows" could be
used by sfq in the future as a parameter, we shouldn't currently
change it's meaning. This patch reverts my previous patch:
commit f867e6af94239a04ec23aeec2fcda5aa58e41db7


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp net-2.6-/net/sched/sch_sfq.c net-2.6+/net/sched/sch_sfq.c
--- net-2.6-/net/sched/sch_sfq.c	2008-07-24 10:26:08.000000000 +0000
+++ net-2.6+/net/sched/sch_sfq.c	2008-07-21 09:32:53.000000000 +0000
@@ -536,14 +536,7 @@ static int sfq_dump(struct Qdisc *sch, s
 
 	opt.limit = q->limit;
 	opt.divisor = SFQ_HASH_DIVISOR;
-	opt.flows = 0;
-	if (q->tail != SFQ_DEPTH) {
-		unsigned int i;
-
-		for (i = 0; i < SFQ_HASH_DIVISOR; i++)
-			if (q->ht[i] != SFQ_DEPTH)
-				opt.flows++;
-	}
+	opt.flows = q->limit;
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
