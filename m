From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Fri, 10 Oct 2008 08:57:35 +0000
Message-ID: <20081010085735.GA5946@ff.dom.local>
References: <20081007220022.GA2664@ami.dom.local> <20081010065934.GA4762@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:56148 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbYJJI5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 04:57:44 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1225766ugf.37
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 01:57:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081010065934.GA4762@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 06:59:34AM +0000, Jarek Poplawski wrote:
...
> But we could consider if, after removing requeuing which mattered
> here, some change is needed in "proper" way of limiting such effects
> of wrong parameters or hardware errors (like the size of mbuffer etc.)?

Simon,

If you could find "a minute", please try if this patch changes anything
e.g. for n = 1000?

Thanks,
Jarek P.

---

 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d14f020..3fe0a98 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1416,7 +1416,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
+		cl->mbuffer = 10 * PSCHED_TICKS_PER_SEC;	/* 10sec */
 		cl->t_c = psched_get_time();
 		cl->cmode = HTB_CAN_SEND;
 
