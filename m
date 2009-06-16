From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] Re: iproute2 action/policer question
Date: Tue, 16 Jun 2009 20:33:55 +0200
Message-ID: <20090616183355.GA3800@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:39643 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbZFPSfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 14:35:47 -0400
Received: by bwz9 with SMTP id 9so4278689bwz.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 11:35:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1245072728.3948.14.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is take 2 with Jamal's ack, and Pawel's name "simplified".
Pawel, if you're not OK with this feel free to send your "Reported-by"
line, and I hope David will replace it.

Thanks,
Jarek P.
-------------------> take 2
pkt_sched: Update drops stats in act_police

Action police statistics could be misleading because drops are not
shown when expected.

With feedback from: Jamal Hadi Salim <hadi@cyberus.ca>

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
---

 net/sched/act_police.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index f8f047b..723964c 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -294,6 +294,8 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 	if (police->tcfp_ewma_rate &&
 	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
+		if (police->tcf_action == TC_ACT_SHOT)
+			police->tcf_qstats.drops++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
 	}
@@ -327,6 +329,8 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 	}
 
 	police->tcf_qstats.overlimits++;
+	if (police->tcf_action == TC_ACT_SHOT)
+		police->tcf_qstats.drops++;
 	spin_unlock(&police->tcf_lock);
 	return police->tcf_action;
 }
