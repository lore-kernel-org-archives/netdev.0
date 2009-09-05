From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Sat, 05 Sep 2009 19:02:00 +0200
Message-ID: <4AA29988.2090100@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet> <20090905.002705.16361217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090103020006050906090901"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57687 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbZIERCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 13:02:01 -0400
In-Reply-To: <20090905.002705.16361217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090103020006050906090901
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri,  4 Sep 2009 18:41:12 +0200 (MEST)
> 
>> Any comments and test results welcome :)
> 
> This looks really nice.  I have them already checked into my
> local net-next-2.6 tree and will push them out after I do
> some multiqueue testing with NIU.

Thanks. Attached is a small fix on top hat fixes inverted logic
in mq_destroy().






--------------090103020006050906090901
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 5e453fd..c84dec9 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -26,7 +26,7 @@ static void mq_destroy(struct Qdisc *sch)
 	struct mq_sched *priv = qdisc_priv(sch);
 	unsigned int ntx;
 
-	if (priv->qdiscs)
+	if (!priv->qdiscs)
 		return;
 	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
 		qdisc_destroy(priv->qdiscs[ntx]);

--------------090103020006050906090901--
