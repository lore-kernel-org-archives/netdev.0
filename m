From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/6] pkt_sched: sch_generic: Add generic qdisc->ops->peek()
   implementation.
Date: Thu, 16 Oct 2008 22:59:02 +0200
Message-ID: <48F7AB16.6000101@gmail.com>
References: <20081016094748.GD19019@ff.dom.local> <48F73159.4060700@trash.net> <20081016124315.GA20302@ff.dom.local> <48F73782.1090003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:21990 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbYJPU6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 16:58:42 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1852303ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 13:58:39 -0700 (PDT)
In-Reply-To: <48F73782.1090003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 10/16/2008 02:45 PM:

> Jarek Poplawski wrote:
>> On Thu, Oct 16, 2008 at 02:19:37PM +0200, Patrick McHardy wrote:
>>> Jarek Poplawski wrote:
>>>> pkt_sched: sch_generic: Add generic qdisc->ops->peek() implementation.
>>>>
>>>> +	if (qops->peek == NULL)
>>>> +		qops->peek = noop_qdisc_ops.peek;
>>>>  	if (qops->dequeue == NULL)
>>>>  		qops->dequeue = noop_qdisc_ops.dequeue;
>>> ->dequeue and ->peek are somewhat tied together, so I think we should
>>> only use the noop variants if both are unset. Whether this should be
>>> checked here of before merging new qdiscs is a different question of
>>> course :)
>> Actually, there is much less users of ->peek. Do you mean to always check
>> for NULL before using? It was meant mainly for these non-work-conserving
>> qdisc in case patch 6/6 isn't merged. Of course, IMHO it should be enough
>> to implement this always (while merging), but this code above could be
>> misleading what is optional/mandatory. (Please make it clear which way do
>> you prefer and I'll redo, no problem.)
> 
> No, I meant that peek = noop_qdisc_ops.peek and dequeue = something_else
> doesn't make much sense. But I think declaring this an API usage error
> and catching it during review is fine.

As a matter of fact I treated this more symbolically: to declare the methods
which don't need checking. Is it possible to forget about ->dequeue()? And
after all, all qdisc but ingress declare this, so logically this could be
removed.

Jarek P.
