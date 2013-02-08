From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 2/7] htb: fix values in opt dump
Date: Fri, 08 Feb 2013 07:54:09 -0800
Message-ID: <1360338849.28557.98.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:42122 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946644Ab3BHPyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 10:54:14 -0500
Received: by mail-da0-f48.google.com with SMTP id v40so1836458dad.21
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 07:54:13 -0800 (PST)
In-Reply-To: <1360328327-7144-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> in htb_change_class() cl->buffer and cl->buffer are stored in ns.
> So in dump, convert them back to psched ticks.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_htb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 476992c..14a83dc 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1135,9 +1135,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
>  	memset(&opt, 0, sizeof(opt));
>  
>  	opt.rate.rate = cl->rate.rate_bps >> 3;
> -	opt.buffer = cl->buffer;
> +	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
>  	opt.ceil.rate = cl->ceil.rate_bps >> 3;
> -	opt.cbuffer = cl->cbuffer;
> +	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
>  	opt.quantum = cl->quantum;
>  	opt.prio = cl->prio;
>  	opt.level = cl->level;

Acked-by: Eric Dumazet <edumazet@google.com>

Isnt it a patch for net tree (and stable) ?

A bug origin (commit id/title) is welcomed to ease stable team work.
