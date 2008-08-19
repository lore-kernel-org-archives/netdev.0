From: Patrick McHardy <kaber@trash.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 15:08:57 +0200
Message-ID: <48AAC5E9.7050809@trash.net>
References: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55182 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbYHSNJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:09:00 -0400
In-Reply-To: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
>> In fact, as I look at how TBF and NETEM want to use ->requeue() they
>> could just the same implement it using my suggested alternative for
>> ->requeue() which is just an SKB list ala gso_list hung off of the
>> qdisc.
> 
> For TBF at least its requeue is actually a bit more sophisticated.
> For example, if you hang a prio qdisc off a TBF, then when the
> packet is requeued into the prio, the next time TBF dequeues it,
> it may get a different packet (of a higher priority).
> 
> If you stick it to a list without requeueing, then packets of a
> higher priority won't be able to jump the queue anymore.
> 
> It might be possible to rewrite TBF to not use requeueing, after
> all HTB does it all without requeueing.  However as it stands,
> TBF does need it.
> 
> I haven't followed this thread closely so what is the main problem
> with requeueing (apart from being abused by things like LLTX drivers
> and/or NETEM, nothing other than qdiscs like TBF should use it)?
> 
> Another possibility would to replace requeue by a peek+force_dequeue
> interface, where you can peek at the next packet, and you could then
> dequeue that particular packet if you're satisfied.

That would be fine for TBF since it only needs to check whether
the current packet exceeds the limit and reschedule otherwise.
HFSC OTOH really needs to know the length of the next packet for
calculating the deadline.
