From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 4/7] htb: initialize cl->tokens and cl->ctokens
 correctly
Date: Fri, 08 Feb 2013 08:36:24 -0800
Message-ID: <1360341384.28557.100.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:53786 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760098Ab3BHQg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:36:28 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so1874634dak.39
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:36:28 -0800 (PST)
In-Reply-To: <1360328327-7144-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> These are in ns so convert from ticks to ns.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_htb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 547912e9..2b22544 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1459,8 +1459,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
>  		cl->parent = parent;
>  
>  		/* set class to be in HTB_CAN_SEND state */
> -		cl->tokens = hopt->buffer;
> -		cl->ctokens = hopt->cbuffer;
> +		cl->tokens = PSCHED_TICKS2NS(hopt->buffer);
> +		cl->ctokens = PSCHED_TICKS2NS(hopt->cbuffer);
>  		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
>  		cl->t_c = psched_get_time();
>  		cl->cmode = HTB_CAN_SEND;

Acked-by: Eric Dumazet <edumazet@google.com>
