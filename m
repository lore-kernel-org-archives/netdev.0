From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5] PKT_SCHED: Qdisc are not supposed to dump
	TCA_STATS themselves
Date: 09 Oct 2004 11:48:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097336911.1051.149.camel@jzny.localdomain>
References: <20041007010146.GA18621@postel.suug.ch>
	 <20041007010819.GF18621@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041007010819.GF18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


1-4 look good. 

Caveat to note Dave: both old TC_STAT as well as new TC_STAT2 will be
generated. Newer software can ignore TC_STAT and older s/ware can ignore
TC_STAT2.

patch 5 is a fix thats independent to 1-4 and should be applied
regardless of the status of 1-4

cheers,
jamal, semi-alive



On Wed, 2004-10-06 at 21:08, Thomas Graf wrote:
> hfsc and htb qdisc are not supposed to copy TCA_STATS
> on their own and queue length statistic is already
> updated in generic code part.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c
> --- linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c	2004-10-07 00:32:25.000000000 +0200
> +++ linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c	2004-10-07 00:55:35.000000000 +0200
> @@ -1653,11 +1653,6 @@
>  
>  	qopt.defcls = q->defcls;
>  	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
> -
> -	sch->stats.qlen = sch->q.qlen;
> -	if (qdisc_copy_stats(skb, &sch->stats, sch->stats_lock) < 0)
> -		goto rtattr_failure;
> -
>  	return skb->len;
>  
>   rtattr_failure:
> diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c linux-2.6.9-rc3-bk6/net/sched/sch_htb.c
> --- linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c	2004-10-07 00:32:25.000000000 +0200
> +++ linux-2.6.9-rc3-bk6/net/sched/sch_htb.c	2004-10-07 00:55:22.000000000 +0200
> @@ -1332,8 +1332,6 @@
>  	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
>  	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
>  	rta->rta_len = skb->tail - b;
> -	sch->stats.qlen = sch->q.qlen;
> -	RTA_PUT(skb, TCA_STATS, sizeof(sch->stats), &sch->stats);
>  	HTB_QUNLOCK(sch);
>  	return skb->len;
>  rtattr_failure:
> 
> 
