From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 5/7] sch: make htb_rate_cfg and functions
 around that generic
Date: Fri, 08 Feb 2013 08:39:49 -0800
Message-ID: <1360341589.28557.102.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:34251 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946466Ab3BHQjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:39:53 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1880033dak.33
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:39:52 -0800 (PST)
In-Reply-To: <1360328327-7144-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> As it is going to be used in tbf as well, push these to generic code.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/net/sch_generic.h | 18 +++++++++++++
>  net/sched/sch_generic.c   | 37 +++++++++++++++++++++++++++
>  net/sched/sch_htb.c       | 65 +++++++----------------------------------------
>  3 files changed, 64 insertions(+), 56 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 2d06c2a..c7e5512 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -679,4 +679,22 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
>  }
>  #endif
>  
> +struct psched_ratecfg {
> +	u64 rate_bps;
> +	u32 mult;
> +	u32 shift;
> +};
> +
> +static inline u64 psched_l2t_ns(struct psched_ratecfg *r, unsigned int len)

 const struct psched_ratecfg *r

> +{
> +	return ((u64)len * r->mult) >> r->shift;
> +}
> +
> +extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate);
> +
> +static inline u32 psched_ratecfg_getrate(struct psched_ratecfg *r)

const struct psched_ratecfg *r

> +{
> +	return r->rate_bps >> 3;
> +}
> +

other than that, patch is fine.

Acked-by: Eric Dumazet <edumazet@google.com>
