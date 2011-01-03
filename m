From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_red: report backlog information
Date: Mon, 03 Jan 2011 19:11:38 +0100
Message-ID: <1294078298.2892.1111.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <1294062755.2472.11.camel@mojatatu>
	 <1294063372.2892.408.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49312 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab1ACSLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 13:11:47 -0500
Received: by wwi17 with SMTP id 17so14079839wwi.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 10:11:46 -0800 (PST)
In-Reply-To: <1294063372.2892.408.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide child qdisc backlog (byte count) information so that "tc -s
qdisc" can report it to user.

packet count is already correctly provided.

qdisc red 11: parent 1:11 limit 60Kb min 15Kb max 45Kb ecn 
 Sent 3116427684 bytes 1415782 pkt (dropped 8, overlimits 7866 requeues 0) 
 rate 242385Kbit 13630pps backlog 13560b 8p requeues 0 
  marked 7865 early 1 pdrop 7 other 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_red.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 8d42bb3..a67ba3c 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -239,6 +239,7 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.Scell_log	= q->parms.Scell_log,
 	};
 
+	sch->qstats.backlog = q->qdisc->qstats.backlog;
 	opts = nla_nest_start(skb, TCA_OPTIONS);
 	if (opts == NULL)
 		goto nla_put_failure;


