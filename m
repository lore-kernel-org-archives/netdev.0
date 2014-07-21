From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] skbedit: allow the user to specify bitmask for mark
Date: Mon, 21 Jul 2014 16:04:55 +0400
Message-ID: <53CD01E7.50004@cogentembedded.com>
References: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Antonio Quartulli <antonio@meshcoding.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:51418 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002AbaGUME7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 08:04:59 -0400
Received: by mail-lb0-f173.google.com with SMTP id p9so1513164lbv.32
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 05:04:58 -0700 (PDT)
In-Reply-To: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-07-2014 12:35, Antonio Quartulli wrote:

> From: Antonio Quartulli <antonio@open-mesh.com>

> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.

> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.

> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
[...]

> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> index fcfeeaf..5fca32b 100644
> --- a/net/sched/act_skbedit.c
> +++ b/net/sched/act_skbedit.c
> @@ -43,8 +43,12 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
>   	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
>   	    skb->dev->real_num_tx_queues > d->queue_mapping)
>   		skb_set_queue_mapping(skb, d->queue_mapping);
> -	if (d->flags & SKBEDIT_F_MARK)
> -		skb->mark = d->mark;
> +	if (d->flags & SKBEDIT_F_MARK) {
> +		/* unset all the bits in the mask */
> +		skb->mark = skb->mark & ~d->mask;

    Why not 'skb->mark &= ~d->mask;'?

> +		/* assign the mark value for the masked bit only */
> +		skb->mark |= d->mark & d->mask;
> +	}
>
>   	spin_unlock(&d->tcf_lock);
>   	return d->tcf_action;
[...]

WBR, Sergei
