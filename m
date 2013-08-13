From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xfrm: make local error reporting more
 robust
Date: Tue, 13 Aug 2013 16:35:07 -0700 (PDT)
Message-ID: <20130813.163507.1784421467479379649.davem@davemloft.net>
References: <20130810161629.GR14001@order.stressinduktion.org>
	<20130812055414.GK25511@secunet.com>
	<20130813015644.GC27385@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, vi0oss@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756931Ab3HMXfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:35:08 -0400
In-Reply-To: <20130813015644.GC27385@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 13 Aug 2013 03:56:44 +0200

> On Mon, Aug 12, 2013 at 07:54:14AM +0200, Steffen Klassert wrote:
>> On Sat, Aug 10, 2013 at 06:16:29PM +0200, Hannes Frederic Sowa wrote:
>> > 
>> > Seems skb->encapsulated helps, but I still have to wire it up for the ipv6
>> > tunnels.
>> > 
>> > I just prototyped this patch, but I fear I now introduced a dependency
>> > from core xfrm to ipv6, which I would like to have prevented (this would
>> > even happen if I put xfrm_local_error in a header file). Is this actually
>> > a problem? I fear so. The other way would be to put the local_error
>> > handler as function pointers somewhere reachable from struct sock.
>> > 
>> 
>> Maybe we should put a local_error() function pointer to struct
>> xfrm_state_afinfo and call it via inner_mode->afinfo->local_error().
>> 
>> This should always call the right local_error function and we
>> would not need to touch generic networking code to fix it.
> 
> Sorry, had to do a v2, because I missed two more unsafe skb->sk dereferences.
> I will post a further one (unsafe determination of mtu) as a seperate patch
> (needs its own commit message).
> 
> [PATCH net-next v2] xfrm: make local error reporting more robust

FWIW, this looks fine to me, and I hope Steffen will take care of
it soon.
