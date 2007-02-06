From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [patch 01/11] user of the jiffies rounding code: Networking
Date: Tue, 06 Feb 2007 10:45:41 -0800
Message-ID: <45C8CCD5.3030202@intel.com>
References: <200702060031.l160VtQ3004618@shell0.pdx.osdl.net> <20070205.180111.36663426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, arjan@linux.intel.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33698 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964784AbXBFSpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:45:51 -0500
In-Reply-To: <20070205.180111.36663426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Mon, 05 Feb 2007 16:30:52 -0800
> 
>> From: Arjan van de Ven <arjan@linux.intel.com>
>>
>> This patch introduces users of the round_jiffies() function in the networking
>> code.
>>
>> These timers all were of the "about once a second" or "about once every X
>> seconds" variety and several showed up in the "what wakes the cpu up" profiles
>> that the tickless patches provide.  Some timers are highly dynamic based on
>> network load; but even on low activity systems they still show up so the
>> rounding is done only in cases of low activity, allowing higher frequency
>> timers in the high activity case.
>>
>> The various hardware watchdogs are an obvious case; they run every 2 seconds
>> but aren't otherwise specific of exactly when they need to run.
>>
>> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I pulled in everything except the e1000 driver change, Jeff please
> suck that in, thanks.

Jeff,

And add my:

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>


Thanks

Auke

> 
> Arjan, btw:
> 
>> +	if (dst_gc_timer_expires > 4*HZ)
>> +		mod_timer(&dst_gc_timer,
>> +			round_jiffies(jiffies + dst_gc_timer_expires));
>> +	else
>> +		mod_timer(&dst_gc_timer, jiffies + dst_gc_timer_expires);
>    ^^^^^^^^^^^^^
> 
> That line begins "TAB SPACE TAB", and lo' and behold GIT
> catch this when I applied it :-)  I fixed it up by hand
> and reapplied, so don't worry about this instance.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
