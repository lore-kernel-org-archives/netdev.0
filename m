From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [2.4.20] filter_list destroy fix in net/sched/sch_prio.c
Date: Thu, 10 Apr 2003 13:57:46 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030410135727.M86925@shell.cyberus.ca>
References: <E1B7C89B8DCB084C809A22D7FEB90B381773AD@frodo.avalon.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "" <linux-kernel@vger.kernel.org>,
   "" <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Dimitry V. Ketov" <Dimitry.Ketov@avalon.ru>
In-Reply-To: <E1B7C89B8DCB084C809A22D7FEB90B381773AD@frodo.avalon.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Looks good to me.

cheers,
jamal

On Thu, 10 Apr 2003, Dimitry V. Ketov wrote:

> The prio qdisc does not destroy its filter list, when someone deletes
> qdisc from interface without explicit filter deleting.
> This patch fixes that behavior.
>
> --- linux-2.4.20/net/sched/sch_prio.c	Sat Aug  3 04:39:46 2002
> +++ linux/net/sched/sch_prio.c	Thu Apr 10 17:52:55 2003
> @@ -158,11 +158,19 @@
>  {
>  	int prio;
>  	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
> +	struct tcf_proto *tp;
>
>  	for (prio=0; prio<q->bands; prio++) {
>  		qdisc_destroy(q->queues[prio]);
>  		q->queues[prio] = &noop_qdisc;
>  	}
> +
> +	while((tp = q->filter_list) != NULL)
> +	{
> +		q->filter_list = tp->next;
> +		tp->ops->destroy(tp);
> +	}
> +
>  	MOD_DEC_USE_COUNT;
>  }
>
>
>
>
