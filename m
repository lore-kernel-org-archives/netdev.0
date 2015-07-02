From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 3/6] net_sched: act: make tcfg_pval non zero
Date: Thu, 02 Jul 2015 08:33:53 -0700
Message-ID: <559559E1.5090605@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35453 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbGBPd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 11:33:58 -0400
Received: by obbop1 with SMTP id op1so52026154obb.2
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 08:33:57 -0700 (PDT)
In-Reply-To: <1435842455-30501-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> First step for gact RCU operation :
> 
> Instead of testing if tcfg_pval is zero or not, just make it 1.
> 
> No change in behavior, but slightly faster code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---
>  net/sched/act_gact.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
> index a4f8af29ee30..42284aad77dd 100644
> --- a/net/sched/act_gact.c
> +++ b/net/sched/act_gact.c

Acked-by: John Fastabend <john.r.fastabend@intel.com>

> @@ -28,14 +28,14 @@
>  #ifdef CONFIG_GACT_PROB
>  static int gact_net_rand(struct tcf_gact *gact)
>  {
> -	if (!gact->tcfg_pval || prandom_u32() % gact->tcfg_pval)
> +	if (prandom_u32() % gact->tcfg_pval)
>  		return gact->tcf_action;
>  	return gact->tcfg_paction;
>  }
>  
>  static int gact_determ(struct tcf_gact *gact)
>  {
> -	if (!gact->tcfg_pval || gact->tcf_bstats.packets % gact->tcfg_pval)
> +	if (gact->tcf_bstats.packets % gact->tcfg_pval)
>  		return gact->tcf_action;
>  	return gact->tcfg_paction;
>  }
> @@ -105,7 +105,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
>  #ifdef CONFIG_GACT_PROB
>  	if (p_parm) {
>  		gact->tcfg_paction = p_parm->paction;
> -		gact->tcfg_pval    = p_parm->pval;
> +		gact->tcfg_pval    = max_t(u16, 1, p_parm->pval);
>  		gact->tcfg_ptype   = p_parm->ptype;
>  	}
>  #endif
> 
