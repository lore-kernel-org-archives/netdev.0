From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 7/7] tbf: ignore max_size check for gso skbs
Date: Fri, 08 Feb 2013 08:43:18 -0800
Message-ID: <1360341798.28557.105.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61417 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946552Ab3BHQnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:43:21 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so2128894pab.5
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:43:21 -0800 (PST)
In-Reply-To: <1360328327-7144-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> This check made bigger packets incorrectly dropped. Remove this
> limitation for gso skbs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_tbf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 35bfd49..7ee5bff 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	if (qdisc_pkt_len(skb) > q->max_size)
> +	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
>  		return qdisc_reshape_fail(skb, sch);
>  
>  	ret = qdisc_enqueue(skb, q->qdisc);

Acked-by: Eric Dumazet <edumazet@gogle.com>
