From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lmc: Read outside array bounds
Date: Sun, 09 Aug 2009 21:27:25 -0700 (PDT)
Message-ID: <20090809.212725.218498673.davem@davemloft.net>
References: <4A6B84A9.7020506@gmail.com>
	<20090728144307.c189810b.akpm@linux-foundation.org>
	<4A7C401B.7090301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZHJE1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:27:16 -0400
In-Reply-To: <4A7C401B.7090301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 07 Aug 2009 16:54:19 +0200

> If dev_alloc_skb() fails on the first iteration of the allocation loop, and we
> break out of the loop, then we end up writing before the start of the array.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>> First of all, if we allocated at least one buffer we should
>> mark the last one in the code right after this loop.
>> 
>> Second of all, we should purge the TX skbs in the next
>> loop even if we could not allocate even one RX buffer.
>>
>> The thing to do is probably to guard the set of "[i-1]" RX ring
>> accesses with a "if (i != 0)" check.
> 
> Forgot a bit about this one, but I hope this is what you meant?

It's not correct to limit the TX ring loop by how many RX
ring buffers we've been able to successfully allocate,
that doesn't make any sense.

I'm talking about the second loop which you unexplainably
changed to "for (j = 0; j < i; ..."

I'm not applying this.
