From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in
 tcf_exts_exec
Date: Sun, 30 Jul 2017 15:48:24 -0400
Message-ID: <c157148b-2e6c-6934-2d54-04d42a0a262c@mojatatu.com>
References: <20170728144042.6380-1-jiri@resnulli.us>
 <20170728144042.6380-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36977 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754308AbdG3Ts0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:48:26 -0400
Received: by mail-io0-f195.google.com with SMTP id c74so9461040iod.4
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:48:26 -0700 (PDT)
In-Reply-To: <20170728144042.6380-5-jiri@resnulli.us>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am probably missing something. All those changes to just
replace "if (exts->nr_actions)" with "if (tcf_exts_has_actions(exts))" ?

cheers,
jamal

On 17-07-28 10:40 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Use the tcf_exts_has_actions helper instead or directly testing
> exts->nr_actions in tcf_exts_exec.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>   include/net/pkt_cls.h | 46 +++++++++++++++++++++++-----------------------
>   1 file changed, 23 insertions(+), 23 deletions(-)
> 
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 7f25636..322a282 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -177,29 +177,6 @@ tcf_exts_stats_update(const struct tcf_exts *exts,
>   }
>   
>   /**
> - * tcf_exts_exec - execute tc filter extensions
> - * @skb: socket buffer
> - * @exts: tc filter extensions handle
> - * @res: desired result
> - *
> - * Executes all configured extensions. Returns 0 on a normal execution,
> - * a negative number if the filter must be considered unmatched or
> - * a positive action code (TC_ACT_*) which must be returned to the
> - * underlying layer.
> - */
> -static inline int
> -tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
> -	       struct tcf_result *res)
> -{
> -#ifdef CONFIG_NET_CLS_ACT
> -	if (exts->nr_actions)
> -		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
> -				       res);
> -#endif
> -	return 0;
> -}
> -
> -/**
>    * tcf_exts_has_actions - check if at least one action is present
>    * @exts: tc filter extensions handle
>    *
> @@ -229,6 +206,29 @@ static inline bool tcf_exts_has_one_action(struct tcf_exts *exts)
>   #endif
>   }
>   
> +/**
> + * tcf_exts_exec - execute tc filter extensions
> + * @skb: socket buffer
> + * @exts: tc filter extensions handle
> + * @res: desired result
> + *
> + * Executes all configured extensions. Returns 0 on a normal execution,
> + * a negative number if the filter must be considered unmatched or
> + * a positive action code (TC_ACT_*) which must be returned to the
> + * underlying layer.
> + */
> +static inline int
> +tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
> +	      struct tcf_result *res)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +	if (tcf_exts_has_actions(exts))
> +		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
> +				       res);
> +#endif
> +	return 0;
> +}
> +
>   int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
>   		      struct nlattr **tb, struct nlattr *rate_tlv,
>   		      struct tcf_exts *exts, bool ovr);
> 
