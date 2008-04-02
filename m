From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Wed, 02 Apr 2008 17:26:45 +0100
Message-ID: <47F3B3C5.6000701@andyfurniss.entadsl.com>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:42051 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753067AbYDBQZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 12:25:32 -0400
In-Reply-To: <47F37E04.4010001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andy Furniss wrote:
>> Andy Furniss wrote:
>>
>>> It's cool being able to see the sfq flows.
>>
>> It's also interesting to notice that allot varies so much.
>>
>> I have seen +/- 10 * my quantum which I didn't expect, I wonder if it 
>> needs to be cleared when a flow empties or something.
>>
>> The source for sfq is a bit hard to follow so I don't really know 
>> what's happening. I was dropping with limit of 40 (about a second at 
>> my rate) and had quite a few connections active, hashing on dst.
>>
>> tcpdump also shows that single flows are getting 3/4/5 packets 
>> dequeued in a row when there are other flows active.
>>
>> I guess it's hard to tell the state at any one instant when dropping 
>> and making flows dis/reappear but it does seem to behave in a way that 
>> amplifies burstyness.
>>
>> My quantum = mtu + 14 and there are no giants.
> 
> 
> I'm not really sure myself. SFQ and CBQ DRR differ slightly from
> the original DRR algorithm by allowing the quantum to go negative
> and carrying it over in the next round, where it has to be made
> up for. CBQ DRR differs from SFQ in that it keeps an inactive
> flow (==empty queue) active until it reaches a positive quantum
> again, which is necessary for this implementation if you want
> to reset the quantum to avoid having a bursty flow send out its
> last packet by overusing its quantum, then going passive and
> immediately active again with a full new quantum. This would
> cause unfairness against constantly active flows. CBQ does
> not reset the quantum when activating a class though, which
> also looks like a bug.
> 
> I haven't fully understood the differences between the SFQ/CBQ
> DRR implementations and the original DRR algorithm, but I'm
> looking into it for other reasons anyways (my DRR scheduler
> uses a similar implementation because it avoids the need to
> requeue and I want to properly understand this before pushing
> it upstream), so I can hopefully soon tell you more :)
> 

OK - FWIW I've been looking harder and have now seen the full range of 
+/- 32k so I assume it's just not getting initialised properly.

Andy.


