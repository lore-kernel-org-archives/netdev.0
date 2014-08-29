From: Michael Heimpold <mhei@heimpold.de>
Subject: Re: [PATCH net-next 5/5] sched: replace bare printks
Date: Fri, 29 Aug 2014 22:12:04 +0200
Message-ID: <2929572.cMoKUE6Fhc@kerker>
References: <20140829070918.508987897@networkplumber.org> <20140829071035.547171617@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:19143 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbaH2UMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 16:12:09 -0400
In-Reply-To: <20140829071035.547171617@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 29. August 2014, 00:09:23 schrieb Stephen Hemminger:
> Don't use bare printk for error messages.
> Make GRED error an info level message rather than debug which
> is likely to be suppressed.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> 
> --- a/net/sched/act_ipt.c	2014-03-28 11:40:43.000000000 -0700
> +++ b/net/sched/act_ipt.c	2014-08-22 16:53:33.676030680 -0700
> @@ -290,10 +290,10 @@ static int __init ipt_init_module(void)
>  
>  	ret1 = tcf_register_action(&act_xt_ops, IPT_TAB_MASK);
>  	if (ret1 < 0)
> -		printk("Failed to load xt action\n");
> +		pr_err("Failed to load xt action\n");
>  	ret2 = tcf_register_action(&act_ipt_ops, IPT_TAB_MASK);
>  	if (ret2 < 0)
> -		printk("Failed to load ipt action\n");
> +		pr_err("Failed to load ipt action\n");
>  
>  	if (ret1 < 0 && ret2 < 0) {
>  		return ret1;
> --- a/net/sched/act_mirred.c	2014-08-12 13:07:42.000000000 -0700
> +++ b/net/sched/act_mirred.c	2014-08-22 16:54:07.244031579 -0700
> @@ -140,7 +140,7 @@ static int tcf_mirred(struct sk_buff *sk
>  
>  	dev = m->tcfm_dev;
>  	if (!dev) {
> -		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
> +		netdev_notice(dev, "tc mirred: target device is gone\n");
>  		goto out;
>  	}

At my first look, I was wondering whether this could work as 'dev' is not
a valid pointer inside the if statement body. But after trying to trace to call
down, I found that it ends up as
printk("%s(NULL net_device): %pV" ... 
within __netdev_printk.
Is this the desired output in this case?
Or did I miss anything?

>  
> --- a/net/sched/sch_gred.c	2014-03-28 11:40:43.000000000 -0700
> +++ b/net/sched/sch_gred.c	2014-08-22 16:54:47.720032663 -0700
> @@ -456,8 +456,8 @@ static int gred_change(struct Qdisc *sch
>  			if (table->tab[table->def])
>  				def_prio = table->tab[table->def]->prio;
>  
> -			printk(KERN_DEBUG "GRED: DP %u does not have a prio "
> -			       "setting default to %d\n", ctl->DP, def_prio);
> +			pr_info("GRED: DP %u does not have a prio "
> +				"setting default to %d\n", ctl->DP, def_prio);
>  
>  			prio = def_prio;
>  		} else
> 

Best regards,
Michael
