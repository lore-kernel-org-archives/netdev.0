From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] qdisc: add tracepoint qdisc:qdisc_dequeue for dequeued
 SKBs
Date: Tue, 15 Aug 2017 20:31:44 -0600
Message-ID: <6f213e4e-601d-fc84-35d8-8fd9fc0748e7@gmail.com>
References: <150282426296.20350.8045788556432194444.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pstaszewski@itcare.pl
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36630 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbdHPCbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 22:31:47 -0400
Received: by mail-pf0-f172.google.com with SMTP id c28so359178pfe.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 19:31:47 -0700 (PDT)
In-Reply-To: <150282426296.20350.8045788556432194444.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/17 1:11 PM, Jesper Dangaard Brouer wrote:
> diff --git a/include/trace/events/qdisc.h b/include/trace/events/qdisc.h
> new file mode 100644
> index 000000000000..60d0d8bd336d
> --- /dev/null
> +++ b/include/trace/events/qdisc.h
> @@ -0,0 +1,50 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM qdisc
> +
> +#if !defined(_TRACE_QDISC_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_QDISC_H_
> +
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +#include <linux/tracepoint.h>
> +#include <linux/ftrace.h>
> +
> +TRACE_EVENT(qdisc_dequeue,
> +
> +	TP_PROTO(struct Qdisc *qdisc, const struct netdev_queue *txq,
> +		 int packets, struct sk_buff *skb),
> +
> +	TP_ARGS(qdisc, txq, packets, skb),
> +
> +	TP_STRUCT__entry(
> +		__field(	struct Qdisc *,		qdisc	)
> +		__field(const	struct netdev_queue *,	txq	)

Why save qdisc and txq pointers in the tracepoint data?
