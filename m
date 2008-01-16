From: Patrick McHardy <kaber@trash.net>
Subject: Re: Not understand some in htb_do_events function
Date: Wed, 16 Jan 2008 06:15:34 +0100
Message-ID: <478D92F6.6070201@trash.net>
References: <478C86E6.3050508@bigtelecom.ru> <478C87D9.1010305@trash.net> <478CA02A.1070308@cdi.cz> <478CD741.7040004@trash.net> <478D2C85.2090008@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60029 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbYAPFPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:15:53 -0500
In-Reply-To: <478D2C85.2090008@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Devera wrote:
>>
>> So this was meant to protect against endless loops?
>>
>>> We want way to smooth big burst of events over more dequeue invocations
>>> in order to not slow dequeue too much. Constant 500 is max. allowed
>>> "slowdown" of dequeue.
>>> Any bright idea how to do it more elegant, Patrick ?
>>
>>
>> Unfortunately not, but I believe simply removing the limit
>> completely would be better than picking an arbitary value.
> 
> Grrr my comp crashed while I was writing this mail. Well the second
> attempt.
> When we allow unlimited events per dequeue, then there is case where
> all N classes in qdisc can be in the event queue with the same target
> time. Then they will all be acted on in the loop within single dequeue,
> costing us say some milliseconds. Additionaly, it tends to repeat itself
> then in cycles.

I see.

> Maybe it is acceptable but it seemed to me as rather big latency.
> Thus I wanted to do only limited work per dequeue call. One possibility
> is to remove the limit and "see what happend in wild".
> 
> What do u think about to do limited no of transitions and then schedule
> tasklet to do the rest (again in limited buckets) ?


Alternatively we could just remove the printk and do what you
suggested first, return q->now + 1 to immediately continue
processing, but send out a packet first.
