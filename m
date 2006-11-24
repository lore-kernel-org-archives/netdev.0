From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED 04/06]: Fix endless loops (part 2): "simple" qdiscs
Date: Fri, 24 Nov 2006 13:33:50 +0100
Message-ID: <20061124123350.GA1599@ff.dom.local>
References: <20061120130843.22347.67166.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:16779 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S934479AbWKXM1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 07:27:24 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20061120130843.22347.67166.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-11-2006 14:08, Patrick McHardy wrote:
> [NET_SCHED]: Fix endless loops (part 2): "simple" qdiscs
> 
> Convert the "simple" qdiscs to use qdisc_tree_decrease_qlen() where
> necessary:
> 
> - all graft operations
> - destruction of old child qdiscs in prio, red and tbf change operation
> - purging of queue in sfq change operation
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
...
>  net/sched/sch_cbq.c    |    2 +-
...
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 908b10d..ba82dfa 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -1687,7 +1687,7 @@ #endif
>  		sch_tree_lock(sch);
>  		*old = cl->q;
>  		cl->q = new;
> -		sch->q.qlen -= (*old)->q.qlen;
> +		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
>  		qdisc_reset(*old);
>  		sch_tree_unlock(sch);
>

Hello,

Probably it is as usual something with my eyes but
it seems cbq needs in cbq_delete or cbq_destroy_class
some treatment (about qdisc_destroy) similar to htb.

Jarek P.
