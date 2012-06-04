From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drop_monitor: dont sleep in atomic context
Date: Mon, 04 Jun 2012 11:42:22 -0400 (EDT)
Message-ID: <20120604.114222.1218482424480520614.davem@davemloft.net>
References: <1338805099.2760.1798.camel@edumazet-glaptop>
	<20120604104937.GC20232@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab2FDPmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:42:24 -0400
In-Reply-To: <20120604104937.GC20232@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 4 Jun 2012 06:49:37 -0400

> On Mon, Jun 04, 2012 at 12:18:19PM +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> drop_monitor calls several sleeping functions while in atomic context.
>> 
>>  BUG: sleeping function called from invalid context at mm/slub.c:943
>>  in_atomic(): 1, irqs_disabled(): 0, pid: 2103, name: kworker/0:2
>>  Pid: 2103, comm: kworker/0:2 Not tainted 3.5.0-rc1+ #55
>>  Call Trace:
>>   [<ffffffff810697ca>] __might_sleep+0xca/0xf0
>>   [<ffffffff811345a3>] kmem_cache_alloc_node+0x1b3/0x1c0
>>   [<ffffffff8105578c>] ? queue_delayed_work_on+0x11c/0x130
>>   [<ffffffff815343fb>] __alloc_skb+0x4b/0x230
>>   [<ffffffffa00b0360>] ? reset_per_cpu_data+0x160/0x160 [drop_monitor]
>>   [<ffffffffa00b022f>] reset_per_cpu_data+0x2f/0x160 [drop_monitor]
>>   [<ffffffffa00b03ab>] send_dm_alert+0x4b/0xb0 [drop_monitor]
>>   [<ffffffff810568e0>] process_one_work+0x130/0x4c0
>>   [<ffffffff81058249>] worker_thread+0x159/0x360
>>   [<ffffffff810580f0>] ? manage_workers.isra.27+0x240/0x240
>>   [<ffffffff8105d403>] kthread+0x93/0xa0
>>   [<ffffffff816be6d4>] kernel_thread_helper+0x4/0x10
>>   [<ffffffff8105d370>] ? kthread_freezable_should_stop+0x80/0x80
>>   [<ffffffff816be6d0>] ? gs_change+0xb/0xb
>> 
>> Rework the logic to call the sleeping functions in right context.
>> 
>> Use standard timer/workqueue api to let system chose any cpu to perform
>> the allocation and netlink send.
>> 
>> Also avoid a loop if reset_per_cpu_data() cannot allocate memory :
>> use mod_timer() to wait 1/10 second before next try.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
> Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks.
