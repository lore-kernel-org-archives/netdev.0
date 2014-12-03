From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Wed, 3 Dec 2014 15:31:50 +0800
Message-ID: <547EBC66.4040301@huawei.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com> <20141103.122538.387451917276174830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <willemb@google.com>
To: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54299 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbaLCHcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 02:32:06 -0500
In-Reply-To: <20141103.122538.387451917276174830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/11/4 1:25, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 02 Nov 2014 06:19:33 -0800
> 
>> From: Eric Dumazet <edumazet@google.com>
>>
>> net_rx_action() can mask irqs a single time to transfert sd->poll_list
>> into a private list, for a very short duration.
>>
>> Then, napi_complete() can avoid masking irqs again,
>> and net_rx_action() only needs to mask irq again in slow path.
>>
>> This patch removes 2 couples of irq mask/unmask per typical NAPI run,
>> more if multiple napi were triggered.
>>
>> Note this also allows to give control back to caller (do_softirq())
>> more often, so that other softirq handlers can be called a bit earlier,
>> or ksoftirqd can be wakeup earlier under pressure.
>>
>> This was developed while testing an alternative to RX interrupt
>> mitigation to reduce latencies while keeping or improving GRO
>> aggregation on fast NIC.
>>
>> Idea is to test napi->gro_list at the end of a napi->poll() and
>> reschedule one NAPI poll, but after servicing a full round of
>> softirqs (timers, TX, rcu, ...). This will be allowed only if softirq
>> is currently serviced by idle task or ksoftirqd, and resched not needed.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Also applied, thanks Eric.

This patch can resolve my performance problem.
Will/Can this patch queue for stable ?

Regards,
Yang
