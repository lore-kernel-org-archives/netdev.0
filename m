From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net : fix for dst_gc_task not getting scheduled if
 __dst_free() is called consistently
Date: Sat, 19 May 2012 14:36:45 -0400 (EDT)
Message-ID: <20120519.143645.301502060316712408.davem@davemloft.net>
References: <1337420654-28200-1-git-send-email-b15745@freescale.com>
	<1337421863.7029.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b15745@freescale.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab2ESSgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 14:36:51 -0400
In-Reply-To: <1337421863.7029.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 12:04:23 +0200

> On Sat, 2012-05-19 at 04:44 -0500, b15745@freescale.com wrote:
>> From: Rajan Gupta <b15745@freescale.com>
>> 
>> dst_gc_work is cancelled and again rescheduled in __ds_free(). In case
>> __dsf_free() is consistently called dst_gc_work will never get called resulting in
>> memory not getting freed at all until one stops calling __dst_free
>> Signed-off-by: Rajan Gupta <b15745@freescale.com>
>> ---
>>  net/core/dst.c |    1 -
>>  1 file changed, 1 deletion(-)
>> 
>> diff --git a/net/core/dst.c b/net/core/dst.c
>> index 8246d47..6820206 100644
>> --- a/net/core/dst.c
>> +++ b/net/core/dst.c
>> @@ -215,7 +215,6 @@ void __dst_free(struct dst_entry *dst)
>>  	if (dst_garbage.timer_inc > DST_GC_INC) {
>>  		dst_garbage.timer_inc = DST_GC_INC;
>>  		dst_garbage.timer_expires = DST_GC_MIN;
>> -		cancel_delayed_work(&dst_gc_work);
>>  		schedule_delayed_work(&dst_gc_work, dst_garbage.timer_expires);
>>  	}
>>  	spin_unlock_bh(&dst_garbage.lock);
> 
> Strange, I never met this....
> 
> Since "if (dst_garbage.timer_inc > DST_GC_INC)" will be false if
> timer_inc is DST_GC_INC.

I'm not considering this patch at all until we figure out what
the real situation is here.
