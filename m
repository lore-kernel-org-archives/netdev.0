From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v3 10/11] act_police: improved accuracy at high
 rates
Date: Sat, 09 Feb 2013 17:33:47 -0800
Message-ID: <1360460027.20362.4.camel@edumazet-glaptop>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
	 <1360428312-1277-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:39479 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760905Ab3BJBdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 20:33:50 -0500
Received: by mail-pb0-f50.google.com with SMTP id up1so253314pbc.9
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 17:33:50 -0800 (PST)
In-Reply-To: <1360428312-1277-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-09 at 17:45 +0100, Jiri Pirko wrote:
> Current act_police uses rate table computed by the "tc" userspace program,
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

...


> -			ptoks -= L2T_P(police, qdisc_pkt_len(skb));
> +			if (ptoks > (s64) psched_l2t_ns(&police->peak,
> +							police->tcfp_mtu))
> +				ptoks = (s64) psched_l2t_ns(&police->peak,
> +							    police->tcfp_mtu);

Same remark here, this should be in a cached variable.

> +			ptoks -= (s64) psched_l2t_ns(&police->peak,
> +						     qdisc_pkt_len(skb));
>  		}
