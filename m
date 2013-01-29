From: David Miller <davem@davemloft.net>
Subject: Re: Can we replace the msleep(250) in dev.c netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 15:31:16 -0500 (EST)
Message-ID: <20130129.153116.170658846017551064.davem@davemloft.net>
References: <51082A64.2090702@candelatech.com>
	<1359490897.30177.4.camel@edumazet-glaptop>
	<51082FF3.4090805@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab3A2UbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:31:17 -0500
In-Reply-To: <51082FF3.4090805@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 29 Jan 2013 12:24:19 -0800

> On 01/29/2013 12:21 PM, Eric Dumazet wrote:
>> On Tue, 2013-01-29 at 12:00 -0800, Ben Greear wrote:
>>> I think there was a proposal to change it to
>>> schedule_timeout_uninterruptible(1);
>>> some time ago, but that change never made it upstream (at least not in
>>> 3.7.5)?
>>>
>>> Thanks,
>>> Ben
>>>
>>
>> Honestly we should fix the bug at this point, not hide it.
>>
>> We could use msleep(2500) to make sure people will complain ;)
> 
> Well, few will notice that either, or at least are unlikely
> to know what to blame.
> 
> If we should just never reach that code, maybe a WARN_ON_ONCE() when
> we do?

If you only notice some time in the future that something has hung in
this state, the original message could be lost.  Therefore, I
definitely prefer that this thing keeps barking into the logs
periodically.
