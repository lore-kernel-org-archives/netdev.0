From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] qdisc: add tracepoint qdisc:qdisc_dequeue for dequeued
 SKBs
Date: Wed, 16 Aug 2017 07:15:15 +0200
Message-ID: <20170816071515.48d9cc7b@redhat.com>
References: <150282426296.20350.8045788556432194444.stgit@firesoul>
        <6f213e4e-601d-fc84-35d8-8fd9fc0748e7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pstaszewski@itcare.pl, brouer@redhat.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750827AbdHPFPW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 01:15:22 -0400
In-Reply-To: <6f213e4e-601d-fc84-35d8-8fd9fc0748e7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 20:31:44 -0600
David Ahern <dsahern@gmail.com> wrote:

> On 8/15/17 1:11 PM, Jesper Dangaard Brouer wrote:
> > diff --git a/include/trace/events/qdisc.h b/include/trace/events/qdisc.h
> > new file mode 100644
> > index 000000000000..60d0d8bd336d
> > --- /dev/null
> > +++ b/include/trace/events/qdisc.h
> > @@ -0,0 +1,50 @@
> > +#undef TRACE_SYSTEM
> > +#define TRACE_SYSTEM qdisc
> > +
> > +#if !defined(_TRACE_QDISC_H) || defined(TRACE_HEADER_MULTI_READ)
> > +#define _TRACE_QDISC_H_
> > +
> > +#include <linux/skbuff.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/tracepoint.h>
> > +#include <linux/ftrace.h>
> > +
> > +TRACE_EVENT(qdisc_dequeue,
> > +
> > +	TP_PROTO(struct Qdisc *qdisc, const struct netdev_queue *txq,
> > +		 int packets, struct sk_buff *skb),
> > +
> > +	TP_ARGS(qdisc, txq, packets, skb),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	struct Qdisc *,		qdisc	)
> > +		__field(const	struct netdev_queue *,	txq	)  
> 
> Why save qdisc and txq pointers in the tracepoint data?

I wanted to attach a BPF program, and allow it to dereference these
pointers.  Which is done via bpf_probe_read like:

 unsigned int qdisc_flags; 
 bpf_probe_read(&qdisc_flags, sizeof(qdisc_flags), &ctx->qdisc->flags);


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
