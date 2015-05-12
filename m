From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Tue, 12 May 2015 07:22:27 -0700
Message-ID: <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431437838-5478-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38653 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbbELOW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:22:29 -0400
Received: by igbhj9 with SMTP id hj9so15621690igb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 07:22:28 -0700 (PDT)
In-Reply-To: <1431437838-5478-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 15:37 +0200, Florian Westphal wrote:

> 
> Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/dev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e5f77c4..871181a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3540,8 +3540,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
>  		*pt_prev = NULL;
>  	}
>  
> -	qdisc_bstats_update_cpu(cl->q, skb);
> +	qdisc_skb_cb(skb)->pkt_len = skb->len;


A qdisc might have a stab (cf qdisc_calculate_pkt_len() )

>  	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
> +	qdisc_bstats_update_cpu(cl->q, skb);
>  
>  	switch (tc_classify(skb, cl, &cl_res)) {
>  	case TC_ACT_OK:
