From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Mon, 23 Apr 2012 22:46:02 -0400 (EDT)
Message-ID: <20120423.224602.594997774992725103.davem@davemloft.net>
References: <1335201102.5205.28.camel@edumazet-glaptop>
	<CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, maze@google.com, ilpo.jarvinen@helsinki.fi
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab2DXCqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:46:15 -0400
In-Reply-To: <CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 23 Apr 2012 22:39:10 -0400

> On Mon, Apr 23, 2012 at 1:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> commit c8628155ece3 (tcp: reduce out_of_order memory use) took care of
>> coalescing tcp segments provided by legacy devices (linear skbs)
>>
>> We extend this idea to fragged skbs, as their truesize can be heavy.
>>
>> ixgbe for example uses 256+1024+PAGE_SIZE/2 = 3328 bytes per segment.
>>
>> Use this coalescing strategy for receive queue too.
>>
>> This contributes to reduce number of tcp collapses, at minimal cost, and
>> reduces memory overhead and packets drops.
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>
> 
> Thanks for the background info, Eric.

Applied, thanks Eric.

Although I'd like to ask you to clean up tcp_try_coalesce() a bit.

It effectively returns a boolean, but you've clouded this up by
returning an int and defining it in the comment to return "> 0" or
not.

Just make it return a real bool.

I know why you did this, it makes the "eaten" code somewhat simpler in
tcp_data_queue(), but overall it's more confusing how it is now.

People look at how the tcp_try_coalesce() return value is interpreted
and say "in what cases can it return a negative value?"  We both know
it can't, but you have to read the entire function to figure that out.

And that's by definition not intuitive.

Thanks.
