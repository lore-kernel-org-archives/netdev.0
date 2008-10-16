From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/6] pkt_sched: sch_generic: Add generic
	qdisc->ops->peek() implementation.
Date: Thu, 16 Oct 2008 12:43:15 +0000
Message-ID: <20081016124315.GA20302@ff.dom.local>
References: <20081016094748.GD19019@ff.dom.local> <48F73159.4060700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:14337 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbYJPMnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 08:43:22 -0400
Received: by ik-out-1112.google.com with SMTP id c30so2439166ika.5
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 05:43:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F73159.4060700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 02:19:37PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> pkt_sched: sch_generic: Add generic qdisc->ops->peek() implementation.
>>
>
>> +	if (qops->peek == NULL)
>> +		qops->peek = noop_qdisc_ops.peek;
>>  	if (qops->dequeue == NULL)
>>  		qops->dequeue = noop_qdisc_ops.dequeue;
>
> ->dequeue and ->peek are somewhat tied together, so I think we should
> only use the noop variants if both are unset. Whether this should be
> checked here of before merging new qdiscs is a different question of
> course :)

Actually, there is much less users of ->peek. Do you mean to always check
for NULL before using? It was meant mainly for these non-work-conserving
qdisc in case patch 6/6 isn't merged. Of course, IMHO it should be enough
to implement this always (while merging), but this code above could be
misleading what is optional/mandatory. (Please make it clear which way do
you prefer and I'll redo, no problem.)

Jarek P.
