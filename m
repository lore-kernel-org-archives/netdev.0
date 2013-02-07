From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inaccurate packet scheduling
Date: Thu, 07 Feb 2013 09:47:38 -0800
Message-ID: <1360259258.28557.57.camel@edumazet-glaptop>
References: <20130102152601.GB1532@minipsycho.orion>
	 <1357144482.21409.16876.camel@edumazet-glaptop>
	 <20130108133038.GB1621@minipsycho.orion>
	 <20130124080536.GA1598@minipsycho.orion>
	 <1359036087.12374.2088.camel@edumazet-glaptop>
	 <20130129122357.GC7571@minipsycho.orion>
	 <1359475983.30177.2.camel@edumazet-glaptop>
	 <20130130121447.GB1604@minipsycho.orion>
	 <20130207161327.GA1619@minipsycho.brq.redhat.com>
	 <1360255175.28557.55.camel@edumazet-glaptop>
	 <20130207173909.GA1651@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:42246 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759201Ab3BGRrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 12:47:41 -0500
Received: by mail-ia0-f170.google.com with SMTP id k20so3224394iak.15
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 09:47:40 -0800 (PST)
In-Reply-To: <20130207173909.GA1651@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 18:39 +0100, Jiri Pirko wrote:
> Thu, Feb 07, 2013 at 05:39:35PM CET, eric.dumazet@gmail.com wrote:
> >On Thu, 2013-02-07 at 17:13 +0100, Jiri Pirko wrote:
> >
> >> >I tried kernel with this patch in. I also ported
> >> >56b765b79e9a78dc7d3f8850ba5e5567205a3ecd to tbf. I'm getting always the
> >> >similar numbers with iperf. There must be something else needed :/
> >> 
> >> Any other ideas?
> >
> >You didn't post any patch, how can I comment on them ?
> 
> Okay, sorry, here it is. But as I said, it did not help.
> 
> Subject: [patch net-next RFC] tbf: improved accuracy at high rates
> 
> Current TBF uses rate table computed by the "tc" userspace program,
> which has the following issue:
> 
> The rate table has 256 entries to map packet lengths to
> token (time units).  With TSO sized packets, the 256 entry granularity
> leads to loss/gain of rate, making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch explicitly computes
> the time and accounts for packet transmission times with nanosecond
> granularity.
> 
> This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

This patch doesnt change  q->max_size

So you hit this :

if (qdisc_pkt_len(skb) > q->max_size)
    return qdisc_reshape_fail(skb, sch);

I thought this point was already mentioned in my previous mails.
