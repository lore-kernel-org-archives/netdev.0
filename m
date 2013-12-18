From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/8] net_sched: remove get_stats from tc_action_ops
Date: Wed, 18 Dec 2013 09:14:36 -0500
Message-ID: <52B1ADCC.8090901@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33321 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642Ab3LROOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:14:37 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so10311726iec.27
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:14:37 -0800 (PST)
In-Reply-To: <1387167311-14763-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> It is not used.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

> ---
>   include/net/act_api.h | 1 -
>   net/sched/act_api.c   | 4 ----
>   2 files changed, 5 deletions(-)
>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 9e90fdf..04c6825 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -72,7 +72,6 @@ struct tc_action_ops {
>   	__u32 	capab;  /* capabilities includes 4 bit version */
>   	struct module		*owner;
>   	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
> -	int     (*get_stats)(struct sk_buff *, struct tc_action *);
>   	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
>   	int     (*cleanup)(struct tc_action *, int bind);
>   	int     (*lookup)(struct tc_action *, u32);
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 4adbce8..51e28f7 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -637,10 +637,6 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
>   	if (err < 0)
>   		goto errout;
>
> -	if (a->ops != NULL && a->ops->get_stats != NULL)
> -		if (a->ops->get_stats(skb, a) < 0)
> -			goto errout;
> -
>   	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
>   	    gnet_stats_copy_rate_est(&d, &h->tcf_bstats,
>   				     &h->tcf_rate_est) < 0 ||
>
