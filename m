From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Tue, 3 Nov 2009 08:00:22 +0000
Message-ID: <20091103080022.GA6718@ff.dom.local>
References: <4AEF9862.8040404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:58228 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299AbZKCIAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 03:00:24 -0500
Received: by bwz27 with SMTP id 27so7243175bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 00:00:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AEF9862.8040404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-11-2009 03:41, Changli Gao wrote:
> sch_htb.c consume the classes's tokens bellow the HTB_CAN_SEND level.
> 
> When a class enters HTB_MAY_BORROW state, it relies on its parents to
> sent packets. The parent class in HTB_CAN_SEND state only consumes
> itself and its parents's tokens, but ADD tokens to the classes under its
> level. It is totally wrong.

Current code is OK.

> It means that a class, which sends packets
> in ceil rate, can also enter HTB_CAN_SEND state now and then.

Yes, a class is entitled to send on it's own then with it's guaranteed
rate, without depending on borrowing.

Jarek P.

> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> ----
> net/sched/sch_htb.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 85acab9..2705702 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -629,11 +629,10 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
>  		if (cl->level >= level) {
>  			if (cl->level == level)
>  				cl->xstats.lends++;
> -			htb_accnt_tokens(cl, bytes, diff);
>  		} else {
>  			cl->xstats.borrows++;
> -			cl->tokens += diff;	/* we moved t_c; update tokens */
>  		}
> +		htb_accnt_tokens(cl, bytes, diff);
>  		htb_accnt_ctokens(cl, bytes, diff);
>  		cl->t_c = q->now;
> 
