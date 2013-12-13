From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 07:05:17 -0500
Message-ID: <52AAF7FD.3090207@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com> <1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62327 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab3LMMFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 07:05:24 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so2651760ieb.17
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 04:05:24 -0800 (PST)
In-Reply-To: <1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So where is you 0/6? ;->
General: The spirit of the patches i find agreeable.
I am against patch 1. Dont just remove ABI/APIs that exist.
Some of these changes are substantial - did you do any testing?
If you havent I can help - but at minimal i will ask you do so.
I will also do more review then with whatever iteration you have around
sunday. I have other patches i meant to  submit - but i will do them on
top of yours.

cheers,
jamal

On 12/13/13 00:47, Cong Wang wrote:
> It is not used.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
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
