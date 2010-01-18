From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 17:34:54 +0100
Message-ID: <4B548DAE.3000205@trash.net>
References: <4B546F24.6070404@trash.net> <1263832258-30297-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58563 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab0ARQe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 11:34:56 -0500
In-Reply-To: <1263832258-30297-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote:
> This add an additional queuing strategy, called pfifo_head_drop,
> to remove the oldest skb in the case of an overflow within the queue -
> the head element - instead of the last skb (tail). To remove the oldest
> skb in a congested situations is useful for sensor network environments
> where newer packets reflects the superior information.
> 
> Reviewed-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

This looks better than the last one :)

A last comment below, than you can add my

Acked-by: Patrick McHardy <kaber@trash.net>

> +struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
> +	.id		=	"pfifo_head_drop",
> +	.priv_size	=	sizeof(struct fifo_sched_data),
> +	.enqueue	=	pfifo_front_enqueue,
> +	.dequeue	=	qdisc_dequeue_head,
> +	.peek		=	qdisc_peek_head,
> +	.drop		=	qdisc_queue_drop,
> +	.init		=	fifo_init,
> +	.reset		=	qdisc_reset_queue,
> +	.change		=	fifo_init,
> +	.dump		=	fifo_dump,
> +	.owner		=	THIS_MODULE,
> +};
> +EXPORT_SYMBOL(pfifo_head_drop_qdisc_ops);

The EXPORT_SYMBOL shouldn't be needed as sch_fifo can only be
linked statically and no other modules are using this as default.
