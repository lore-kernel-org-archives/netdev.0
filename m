From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Wed, 03 Dec 2014 21:47:47 -0800 (PST)
Message-ID: <20141203.214747.724586077633056397.davem@davemloft.net>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141103.122538.387451917276174830.davem@davemloft.net>
	<547EBC66.4040301@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, willemb@google.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaLDFnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 00:43:25 -0500
In-Reply-To: <547EBC66.4040301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 3 Dec 2014 15:31:50 +0800

> On 2014/11/4 1:25, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sun, 02 Nov 2014 06:19:33 -0800
>> 
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> net_rx_action() can mask irqs a single time to transfert sd->poll_list
>>> into a private list, for a very short duration.
>>>
>>> Then, napi_complete() can avoid masking irqs again,
>>> and net_rx_action() only needs to mask irq again in slow path.
>>>
>>> This patch removes 2 couples of irq mask/unmask per typical NAPI run,
>>> more if multiple napi were triggered.
>>>
>>> Note this also allows to give control back to caller (do_softirq())
>>> more often, so that other softirq handlers can be called a bit earlier,
>>> or ksoftirqd can be wakeup earlier under pressure.
>>>
>>> This was developed while testing an alternative to RX interrupt
>>> mitigation to reduce latencies while keeping or improving GRO
>>> aggregation on fast NIC.
>>>
>>> Idea is to test napi->gro_list at the end of a napi->poll() and
>>> reschedule one NAPI poll, but after servicing a full round of
>>> softirqs (timers, TX, rcu, ...). This will be allowed only if softirq
>>> is currently serviced by idle task or ksoftirqd, and resched not needed.
>>>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> Also applied, thanks Eric.
> 
> This patch can resolve my performance problem.
> Will/Can this patch queue for stable ?

Such an optimization is not appropriate for -stable.
