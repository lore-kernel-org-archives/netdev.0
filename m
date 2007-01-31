From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 14:47:55 +0100
Message-ID: <45C09E0B.6020107@trash.net>
References: <20070131075348.GA1857@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62306 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933276AbXAaNsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 08:48:00 -0500
In-Reply-To: <20070131075348.GA1857@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> This patch adds a dump_stats callback to enable
> printing of basic statistics of prio classes.

> diff -Nurp linux-2.6.20-rc6-/net/sched/sch_prio.c linux-2.6.20-rc6/net/sched/sch_prio.c
> --- linux-2.6.20-rc6-/net/sched/sch_prio.c	2007-01-08 20:23:58.000000000 +0100
> +++ linux-2.6.20-rc6/net/sched/sch_prio.c	2007-01-30 20:26:31.000000000 +0100
> @@ -372,6 +372,23 @@ static int prio_dump_class(struct Qdisc 
>  	return 0;
>  }
>  
> +static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
> +							struct gnet_dump *d)

Please align with struct Qdisc.

> +{
> +	struct prio_sched_data *q = qdisc_priv(sch);
> +	struct Qdisc *cl_q;
> +
> +	if (cl - 1 > q->bands)
> +		return -ENOENT;

This would indicate a bug in prio_walk or prio_get. errno-codes have no
meaning for dump_stats callbacks, either rely on the correctness of
walk/get (as other qdiscs do) or call BUG.

> +
> +	cl_q = q->queues[cl - 1];
> +	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
> +	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
> +		return -1;
> +
> +	return 0;
> +}

ACK for the rest.
