From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: prevent unnecessary reordering
Date: Mon, 28 Apr 2008 17:41:46 +0200
Message-ID: <20080428154146.GC2870@ami.dom.local>
References: <4815B6EA.5070201@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:41295 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936274AbYD1PnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:43:17 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1910974nfb.21
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 08:43:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4815B6EA.5070201@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote, On 04/28/2008 01:37 PM:

> Jarek Poplawski wrote:
>> On 27-04-2008 16:22, Jarek Poplawski wrote:
>>> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
>>>
>> David, as Patrick noticed this patch was wrong and I withdraw it.
>>
>> I still can't see why sfq should have such a low limit,
> 
> It's a useful param which I use - on slow egress I can't see the point 
> of queuing many seconds worth of traffic. It may also help keep stronger 
> connections in check.

I agree the param is useful, but I can't see any technical reason why
sfq can't do a bit more queuing sometimes - especially when we expect
more flows/users per qdisc (probably another param would be necessary
for this).

> When shaping ingress it's essential to drop early to get out of 
> slowstart before the far buffer gets too full.
> 
> 
>> [NET_SCHED] sch_sfq: prevent unnecessary reordering
>>
>> Current check of queue limit in sfq_enqueue() isn't optimal: there
>> is really not much more needed to prevent unnecessary dropping and
>> possible reordering.
> 
> Maybe it makes no difference in the long run, but if you drop and then 
> enqueue a later packet the sender will get to know sooner so congestion 
> control can do it's stuff.

Happilly(?) it looks like my patch will not change here a lot...

Thanks for comments,
Jarek P.
