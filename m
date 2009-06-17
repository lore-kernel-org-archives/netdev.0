From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH v2] Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 11:33:35 +0200
Message-ID: <4A38B86F.90307@itcare.pl>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090616183355.GA3800@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:55144 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051AbZFQJdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 05:33:35 -0400
In-Reply-To: <20090616183355.GA3800@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> Here is take 2 with Jamal's ack, and Pawel's name "simplified".
> Pawel, if you're not OK with this feel free to send your "Reported-by"
> line, and I hope David will replace it.
>
>   
:) it's OK
> Thanks,
> Jarek P.
> -------------------> take 2
> pkt_sched: Update drops stats in act_police
>
> Action police statistics could be misleading because drops are not
> shown when expected.
>
> With feedback from: Jamal Hadi Salim <hadi@cyberus.ca>
>
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
> ---
>
>  net/sched/act_police.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index f8f047b..723964c 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -294,6 +294,8 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
>  	if (police->tcfp_ewma_rate &&
>  	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
>  		police->tcf_qstats.overlimits++;
> +		if (police->tcf_action == TC_ACT_SHOT)
> +			police->tcf_qstats.drops++;
>  		spin_unlock(&police->tcf_lock);
>  		return police->tcf_action;
>  	}
> @@ -327,6 +329,8 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
>  	}
>  
>  	police->tcf_qstats.overlimits++;
> +	if (police->tcf_action == TC_ACT_SHOT)
> +		police->tcf_qstats.drops++;
>  	spin_unlock(&police->tcf_lock);
>  	return police->tcf_action;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

