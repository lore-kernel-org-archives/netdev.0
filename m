From: Patrick McHardy <kaber@trash.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 15:20:04 +0200
Message-ID: <48AAC884.30802@trash.net>
References: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au> <48AAC5E9.7050809@trash.net> <20080819131139.GA5754@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55472 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbYHSNUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:20:08 -0400
In-Reply-To: <20080819131139.GA5754@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 03:08:57PM +0200, Patrick McHardy wrote:
>>> Another possibility would to replace requeue by a peek+force_dequeue
>>> interface, where you can peek at the next packet, and you could then
>>> dequeue that particular packet if you're satisfied.
>> That would be fine for TBF since it only needs to check whether
>> the current packet exceeds the limit and reschedule otherwise.
>> HFSC OTOH really needs to know the length of the next packet for
>> calculating the deadline.
> 
> You mean a peek interface is insufficient for HFSC? Could you
> elaborate?

I might have misunderstood you, but the way I imagine force_dequeue
is that it would give you the packet peeked at, even if a higher
priority packet is available.

But actually I don't understand the use for force_dequeue at all,
assuming ->peek behaves correctly ->dequeue should already hand
out the correct packet.

(Note: Its OK to hand out a different packet if we had a ->enqueue
operation after ->peek since the upper qdisc can just re-peek and
recalculate based on the new highest priority packet).


