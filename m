From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] remove netpoll rx support
Date: Tue, 11 Mar 2014 16:09:31 -0400 (EDT)
Message-ID: <20140311.160931.1395978386605601765.davem@davemloft.net>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755649AbaCKUJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:09:35 -0400
In-Reply-To: <87wqg0cy9d.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Mar 2014 12:48:30 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Tue, 11 Mar 2014 01:43:10 -0700
>>
>>> Furthermore netpoll by it's design depends on the ability to receive
>>> packets in netpoll_poll_dev.  It is a capability I don't think we have
>>> ever used in the mainline kernel but it is a capability that is there
>>> deliberately.  Which means if we want netpoll to not mess with the rx
>>> path we need to change netpoll.
>>
>> This breaks kdump, and any other users of netpoll_rx() et al.
> 
> It does not break kdump.  (kdump starts a new kernel to do it's work). 
> 
> It does break the ancient lkcd netdump that was never merged, and has
> been abandoned (to the best of my knowledge). crash dumps proved
> entirely too fragile to perform from a broken kernel.

I feel like I've mixed this up in the past, multiple times, thanks
for the sanity check.

>> Make the zero budget depend upon us being invoked from hardware
>> irq context, or something like that.
> 
> Good enough.  I will respin my driver patches based on the assumption
> that netpoll will be changed in this way.  There are no dependencies
> for the drivers, I just need to remove my rx path changes.
> 
> We can have the conversation about how to change netpoll in parallel.

Sounds great.
