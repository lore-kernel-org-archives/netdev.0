From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sun, 10 Aug 2008 21:04:58 +0200
Message-ID: <20080810190458.GA7279@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com> <20080802.192639.02765648.davem@davemloft.net> <EA929A9653AAE14F841771FB1DE5A1365F1FDE30F1@rrsmsx501.amr.corp.intel.com> <20080809.002956.58270696.davem@davemloft.net> <20080809223240.GA3085@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:39517 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbYHJTDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 15:03:36 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1470720fkq.5
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 12:03:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080809223240.GA3085@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2008 at 12:32:40AM +0200, Jarek Poplawski wrote:
...
> I guess you're thinking about something bigger, but here is a little,
> maybe unrelated idea, which I think looks reasonable: after changing
> the qdiscs, we should care more about pending activities on the "real"
> one instead of the noop.

Hmm.. Actually, it's completely unreasonable. Let's forget this.

Jarek P.

> ---
> 
>  net/sched/sch_generic.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 7cf83b3..7bce88d 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -658,7 +658,7 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
>  		int val;
>  
>  		dev_queue = netdev_get_tx_queue(dev, i);
> -		q = dev_queue->qdisc;
> +		q = dev_queue->qdisc_sleeping;
>  		root_lock = qdisc_lock(q);
>  
>  		if (lock)
