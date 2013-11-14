From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: fix pacing for small frames
Date: Thu, 14 Nov 2013 14:51:56 -0800
Message-ID: <1384469516.28716.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384455496.28716.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131114.172220.940454781221829007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com,
	ycheng@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f177.google.com ([209.85.161.177]:46237 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab3KNWwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:52:04 -0500
Received: by mail-gg0-f177.google.com with SMTP id f4so1114079ggn.22
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 14:52:00 -0800 (PST)
In-Reply-To: <20131114.172220.940454781221829007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:22 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 Nov 2013 10:58:16 -0800
> 
> > @@ -655,9 +664,6 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
> >  	if (tb[TCA_FQ_INITIAL_QUANTUM])
> >  		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
> >  
> > -	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
> > -		q->flow_default_rate = nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
> > -
> >  	if (tb[TCA_FQ_FLOW_MAX_RATE])
> >  		q->flow_max_rate = nla_get_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
> >  
> 
> I think it's at best confusing to suddenly stop ignoring a configuration
> parameter the user is giving us.
> 
> Can you at least ratelimit warn if the parameter is specified so the user
> has some chance to figure out what is happening?

Oh this parameter was removed in 7eec4174ff29cd
("pkt_sched: fq: fix non TCP flows pacing"), I probably should
have added this warning at that time...

OK, we can warn the user, will send a v2.
