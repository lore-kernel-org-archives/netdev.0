From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Thu, 10 Sep 2009 13:28:59 +0200
Message-ID: <4AA8E2FB.3040809@trash.net>
References: <20090906200409.GB8833@ami.dom.local> <4AA50A49.7010905@trash.net> <20090907192429.GC4451@ami.dom.local> <4AA563B4.1060003@gmail.com> <4AA7D1B3.7010708@trash.net> <20090909195238.GA3043@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59531 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196AbZIJL3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 07:29:01 -0400
In-Reply-To: <20090909195238.GA3043@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Sep 09, 2009 at 06:02:59PM +0200, Patrick McHardy wrote:
>>>>>>> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
>>>>>>> +		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
>>>>>>> +		spin_lock_bh(qdisc_lock(qdisc));
>>>>>>> +		sch->q.qlen		+= qdisc->q.qlen;
>>>>>>> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
>>>>>>> +		sch->bstats.packets	+= qdisc->bstats.packets;
>>>>>>> +		sch->qstats.qlen	+= qdisc->qstats.qlen;
>>>>>> Like in Christoph's case, we should probably use q.qlen instead.
>>>>> Its done a few lines above. This simply sums up all members of qstats.
>>>> AFAICS these members are updated only in tc_fill_qdisc, starting from
>>>> the root, so they might be not up-to-date at the moment, unless I miss
>>>> something.
>>> Yes, we might need an q->ops->update_stats(struct Qdisc *sch) method, and
>>> to recursively call it from mq_update_stats()
>> Unless I'm missing something, that shouldn't be necessary since
>> sch->q.qlen contains the correct sum of all child qdiscs and
>> this is used by tc_fill_qdisc to update qstats.qlen.
> 
> You're perfectly right! (And the code is perfectly misleading.;-)

I'll remove the misleading (and unnecessary) line of code, thanks Jarek.
