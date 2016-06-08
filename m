From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 3/4] sched: remove qdisc_rehape_fail
Date: Wed, 08 Jun 2016 15:08:45 -0700
Message-ID: <1465423725.7945.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465400141-29088-1-git-send-email-fw@strlen.de>
	 <1465400141-29088-4-git-send-email-fw@strlen.de>
	 <1465407776.7945.24.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160608210109.GD29699@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36154 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161175AbcFHWIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:08:47 -0400
Received: by mail-pf0-f194.google.com with SMTP id 62so1372498pfd.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 15:08:47 -0700 (PDT)
In-Reply-To: <20160608210109.GD29699@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-08 at 23:01 +0200, Florian Westphal wrote:

> 
> Would you mind an annotation rather than covering the hole?
> 
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -71,11 +71,11 @@ struct Qdisc {
>         struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>         struct gnet_stats_queue __percpu *cpu_qstats;
>  
> -       struct Qdisc            *next_sched;
> -       struct sk_buff          *gso_skb;
>         /*
>          * For performance sake on SMP, we put highly modified fields at the end
>          */
> +       struct Qdisc            *next_sched ____cacheline_aligned_in_smp;
> +       struct sk_buff          *gso_skb;
> 
> 
> ... it creates 16 byte hole after cpu_qstats and keeps the rest as-is
>  (i.e. next_sched is at beginning of 2nd cacheline, as before the removal).
> 
> I could also cover the hole by moving rcu_head there but it seems fragile
> and doesn't reduce total struct size anyway (we get larger hole at end).
> 
> If you have no objection I'd resubmit the series as-is but with this patch.
> 
> Let me know, thanks Eric!

This all looks fine to me.
