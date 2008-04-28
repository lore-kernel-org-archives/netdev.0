From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: prevent unnecessary reordering
Date: Mon, 28 Apr 2008 12:37:14 +0100
Message-ID: <4815B6EA.5070201@andyfurniss.entadsl.com>
References: <20080428090453.GA4936@ff.dom.local>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:41808 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763049AbYD1LhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 07:37:16 -0400
In-Reply-To: <20080428090453.GA4936@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On 27-04-2008 16:22, Jarek Poplawski wrote:
>> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
>>
> 
> David, as Patrick noticed this patch was wrong and I withdraw it.
> 
> I still can't see why sfq should have such a low limit,

It's a useful param which I use - on slow egress I can't see the point 
of queuing many seconds worth of traffic. It may also help keep stronger 
connections in check.

When shaping ingress it's essential to drop early to get out of 
slowstart before the far buffer gets too full.


> 
> [NET_SCHED] sch_sfq: prevent unnecessary reordering
> 
> Current check of queue limit in sfq_enqueue() isn't optimal: there
> is really not much more needed to prevent unnecessary dropping and
> possible reordering.

Maybe it makes no difference in the long run, but if you drop and then 
enqueue a later packet the sender will get to know sooner so congestion 
control can do it's stuff.

Andy.
