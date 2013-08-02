From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] htb: fix sign extension bug
Date: Fri, 02 Aug 2013 06:36:20 -0700
Message-ID: <1375450580.3927.12.camel@edumazet-glaptop>
References: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
	 <ktfdq8$882$1@ger.gmane.org>
	 <20130801221936.24d4b31e@nehalam.linuxnetplumber.net>
	 <20130801223207.2a9c69e9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53866 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab3HBNgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 09:36:22 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so660192pdj.40
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 06:36:22 -0700 (PDT)
In-Reply-To: <20130801223207.2a9c69e9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 22:32 -0700, Stephen Hemminger wrote:
> When userspace passes a large priority value 
> the assignment of the unsigned value hopt->prio
> to  signed int cl->prio causes cl->prio to become negative and the
> comparison is with TC_HTB_NUMPRIO is always false.
> 
> The result is that HTB crashes by referencing outside
> the array when processing packets. With this patch the large value
> wraps around like other values outside the normal range.
> 
> See: https://bugzilla.kernel.org/show_bug.cgi?id=60669
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> --- a/net/sched/sch_htb.c	2013-06-20 09:22:46.489542435 -0700
> +++ b/net/sched/sch_htb.c	2013-08-01 22:12:43.736307055 -0700
> @@ -100,7 +100,7 @@ struct htb_class {
>  	struct psched_ratecfg	ceil;
>  	s64			buffer, cbuffer;/* token bucket depth/rate */
>  	s64			mbuffer;	/* max wait time */
> -	int			prio;		/* these two are used only by leaves... */
> +	u32			prio;		/* these two are used only by leaves... */
>  	int			quantum;	/* but stored for parent-to-leaf return */
>  
>  	struct tcf_proto	*filter_list;	/* class attached filters */
> --

Thanks Stephen.

Acked-by: Eric Dumazet <edumazet@google.com>

It seems appropriate for net tree (and stable)

We probably should report an error from htb_change_class() ?
