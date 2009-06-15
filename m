From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 23:47:48 +0200
Message-ID: <20090615214748.GA3857@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:35744 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586AbZFOVsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 17:48:01 -0400
Received: by bwz9 with SMTP id 9so3660960bwz.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 14:48:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1245072728.3948.14.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 09:32:08AM -0400, jamal wrote:
> On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:
> 
> > > This is only a sample but is not working
> 
> It does seem to be working!
> How did you reach conclusion it wasnt working?
> 
> > >         Action statistics:
> > >         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues 0)
> > >         rate 0bit 0pps backlog 0b 0p requeues 0

Jamal, after looking into act_gact or act_nat I guess we should update
drops here likewise, unless I miss something?

Pawel, if it works for you could you send your "Tested-by"?

Thanks,
Jarek P.
------------------->
pkt_sched: Update drops stats in act_police

Action police statistics could be misleading because drops are not
shown when expected.

With feedback from: Jamal Hadi Salim <hadi@cyberus.ca>

Reported-by: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
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
