From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Sun, 01 Dec 2013 20:11:10 -0500 (EST)
Message-ID: <20131201.201110.1947727947032213373.davem@davemloft.net>
References: <5292C76E.1070701@huawei.com>
	<52933CC7.9070805@huawei.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7443@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, brouer@redhat.com, jpirko@redhat.com,
	jbrouer@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab3LBBLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:11:12 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7443@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Mon, 25 Nov 2013 12:22:30 -0000

>> From: Yang Yingliang <yangyingliang@huawei.com>
>> 
>> Current max_size is caluated from rate table. Now, the rate table
>> has been replaced and it's wrong to caculate max_size based on this
>> rate table. It can lead wrong calculation of max_size.
>> 
>> The burst in kernel may be lower than user asked, because burst may gets
>> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
>> and it seems we cannot avoid this loss. And burst's value(max_size) based
>> on rate table may be equal user asked. If a packet's length is max_size,
>> this packet will be stalled in tbf_dequeue() because its length is above
>> the burst in kernel so that it cannot get enough tokens. The max_size guards
>> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> 
> Why not adjust the calculations so that the number of allocated tokens
> can go negative?
> 
> So allow the transfer if the number of tokens is +ve and then subtract
> the number needed for the message itself.
> 
> I think this would change the semantics of the configured 'burst' value
> very slightly (to 'at least' from 'at most') but the average would still
> be correct.
> 
> FWIW I've done similar rate limiters that run directly in units of 'time'.
> The fact that system time advances automatically generates credit.

Yang has responded to your concerns, are they addressed?
