From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 14:32:29 +0200
Message-ID: <48F4915D.8000004@trash.net>
References: <20081014095246.GA10804@ff.dom.local> <48F484EB.8000201@trash.net> <20081014122650.GA12373@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34789 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbYJNMcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 08:32:33 -0400
In-Reply-To: <20081014122650.GA12373@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Oct 14, 2008 at 01:39:23PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> The aim of this patch-set is to finish changes proposed by David S.
>>> Miller in his patch-set with the same subject from Mon, 18 Aug 2008.
>>> The first two patches were applied with some modifications, so, to
>>> apply the rest, there were needed some changes.
>>>
>>> Original David's patches include additional info, but signed-off-by
>>> is removed because of changed context. I expect they will be merged
>>> and signed off by David as an author, anyway.
>>>
>>> The qdisc->requeue list idea is to limit requeuing to one level only,
>>> so a parent can requeue to its child only. This list is then tried
>>> first while dequeuing (qdisc_dequeue()), except at the top level,
>>> so packets could be requeued only by qdiscs, not by qdisc_restart()
>>> after xmit errors.
>> I didn't follow the original discussion, but I'm wondering what
>> the reasoning is why these patches won't have negative impact
>> on latency. Consider these two scenarios with HFSC or TBF:
> 
> Hmm... What a pity you couldn't write this a bit earlier, because I've
> just waited with this part for some distinct cons of this solution.

I'm sorry for any wasted effort, I think I mentioned this one or
two month ago, but wasn't able to further participate in the
discussion because I was busy with other things.

> Alas, I can't analyze your concerns at the moment, and I'll try to
> reply in the evening yet, but my idea was this all shouldn't make
> (almost) any visible change just for HFSC, so if it's otherwise,
> something went wrong. IMHO, with this solution hfsc_requeue() way is
> simply realized as a standard now, but I can miss something.

The main difference results from the fact that higher priority
packets can't preempt "peeked" lower priority packets anymore.
The difference this causes obviously depends on the bandwidth,
but in my opinion the impact (as mentioned. 12ms delay for
1500b, 1mbit, rises linearly with bigger packets/less bandwidth)
is large enough to speak against these changes.
