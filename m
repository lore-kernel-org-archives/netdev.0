From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering functionality
 to tfifo qdisc.
Date: Wed, 22 Oct 2008 18:00:06 +0200
Message-ID: <48FF4E06.8040505@trash.net>
References: <20081017130333.GA8297@ff.dom.local>	<48F89D33.9090809@trash.net>	<20081017201210.GA2527@ami.dom.local> <20081021.163605.57275028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55908 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbYJVQAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 12:00:08 -0400
In-Reply-To: <20081021.163605.57275028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Damn hotkeys for sending incomplete mails :)]

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 17 Oct 2008 22:12:10 +0200
> 
>> pkt_sched: sch_netem: Limit packet re-ordering functionality to tfifo qdisc.
>>
>> After introducing qdisc->ops->peek() method the only remaining user of
>> qdisc->ops->requeue() is netem_enqueue() using this for packet
>> re-ordering. According to Patrick McHardy: "a lot of the functionality
>> of netem requires the inner tfifo anyways and rate-limiting is usually
>> done on top of netem. So I would suggest so either hard-wire the tfifo
>> qdisc or at least make the assumption that inner qdiscs are work-
>> conserving." This patch tries the former.
>>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> This is an interesting patch.
> 
> But the thing that strikes me is this: Why don't we just let sch_netem do
> the reordering inside of itself entirely and just get rid of all of this
> ->requeue() business?

I fully agree, keeping all the ->requeue crap around just for this
cornercase doesn't seem like a good decision. Most of the ->requeue
functions are completely inconsistent in their behaviour anyways:
some undo ->enqueue state changes (which is obviously broken for
netem), some don't, some redo checks from ->enqueue (necessary for
netem), some don't (TBF), ...
