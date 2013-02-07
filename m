From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Thu, 7 Feb 2013 19:56:18 +0100
Message-ID: <20130207185618.GB1651@minipsycho.orion>
References: <20130108133038.GB1621@minipsycho.orion>
 <20130124080536.GA1598@minipsycho.orion>
 <1359036087.12374.2088.camel@edumazet-glaptop>
 <20130129122357.GC7571@minipsycho.orion>
 <1359475983.30177.2.camel@edumazet-glaptop>
 <20130130121447.GB1604@minipsycho.orion>
 <20130207161327.GA1619@minipsycho.brq.redhat.com>
 <1360255175.28557.55.camel@edumazet-glaptop>
 <20130207173909.GA1651@minipsycho.orion>
 <1360259258.28557.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:37175 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161017Ab3BGS4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 13:56:23 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so1365294eaa.28
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 10:56:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360259258.28557.57.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 07, 2013 at 06:47:38PM CET, eric.dumazet@gmail.com wrote:
>On Thu, 2013-02-07 at 18:39 +0100, Jiri Pirko wrote:
>> Thu, Feb 07, 2013 at 05:39:35PM CET, eric.dumazet@gmail.com wrote:
>> >On Thu, 2013-02-07 at 17:13 +0100, Jiri Pirko wrote:
>> >
>> >> >I tried kernel with this patch in. I also ported
>> >> >56b765b79e9a78dc7d3f8850ba5e5567205a3ecd to tbf. I'm getting always the
>> >> >similar numbers with iperf. There must be something else needed :/
>> >> 
>> >> Any other ideas?
>> >
>> >You didn't post any patch, how can I comment on them ?
>> 
>> Okay, sorry, here it is. But as I said, it did not help.
>> 
>> Subject: [patch net-next RFC] tbf: improved accuracy at high rates
>> 
>> Current TBF uses rate table computed by the "tc" userspace program,
>> which has the following issue:
>> 
>> The rate table has 256 entries to map packet lengths to
>> token (time units).  With TSO sized packets, the 256 entry granularity
>> leads to loss/gain of rate, making the token bucket inaccurate.
>> 
>> Thus, instead of relying on rate table, this patch explicitly computes
>> the time and accounts for packet transmission times with nanosecond
>> granularity.
>> 
>> This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>This patch doesnt change  q->max_size
>
>So you hit this :
>
>if (qdisc_pkt_len(skb) > q->max_size)
>    return qdisc_reshape_fail(skb, sch);
>
>I thought this point was already mentioned in my previous mails.

Right. I think I get it now. the RFC patch I posted enables possibility
to remove the max_size limitation, right?

I'm not really familliar in this area so I had to stare at the code for
a while.

>
>
>
