From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for the loopback device.
Date: Thu, 27 Sep 2007 01:48:00 -0600
Message-ID: <m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<20070926.220901.51682476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33918 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbXI0HsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 03:48:22 -0400
In-Reply-To: <20070926.220901.51682476.davem@davemloft.net> (David Miller's
	message of "Wed, 26 Sep 2007 22:09:01 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 26 Sep 2007 17:53:40 -0600
>
>> 
>> This patch add support for dynamically allocating the statistics counters
>> for the loopback device and adds appropriate device methods for allocating
>> and freeing the loopback device.
>> 
>> This completes support for creating multiple instances of the loopback
>> device,  in preparation for creating per network namespace instances.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> Applied to net-2.6.24, thanks.
>
>> @@ -155,7 +154,8 @@ static int loopback_xmit(struct sk_buff *skb, struct
> net_device *dev)
>>  	dev->last_rx = jiffies;
>>  
>>  	/* it's OK to use __get_cpu_var() because BHs are off */
>> -	lb_stats = &__get_cpu_var(pcpu_lstats);
>> +	pcpu_lstats = netdev_priv(dev);
>> +	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
>>  	lb_stats->bytes += skb->len;
>>  	lb_stats->packets++;
>>  
>
> I'm going to add a followon change that gets rid of that
> comment about __get_cpu_var() since it is no longer
> relevant.

Good point.

I'm not doing get_cpu/put_cpu so does the comment make sense
in relationship to per_cpu_ptr?

Eric

