From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: fix pacing for small frames
Date: Thu, 14 Nov 2013 17:22:20 -0500 (EST)
Message-ID: <20131114.172220.940454781221829007.davem@davemloft.net>
References: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<1384455496.28716.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com,
	ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758107Ab3KNWWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:22:23 -0500
In-Reply-To: <1384455496.28716.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Nov 2013 10:58:16 -0800

> @@ -655,9 +664,6 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
>  	if (tb[TCA_FQ_INITIAL_QUANTUM])
>  		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
>  
> -	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
> -		q->flow_default_rate = nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
> -
>  	if (tb[TCA_FQ_FLOW_MAX_RATE])
>  		q->flow_max_rate = nla_get_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
>  

I think it's at best confusing to suddenly stop ignoring a configuration
parameter the user is giving us.

Can you at least ratelimit warn if the parameter is specified so the user
has some chance to figure out what is happening?

Thanks.
