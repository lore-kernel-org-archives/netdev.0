From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Tue, 19 Aug 2008 22:50:48 +1000
Message-ID: <E1KVQfg-0001Qf-00@gondolin.me.apana.org.au>
References: <20080817.235237.24119245.davem@davemloft.net>
Cc: jussi.kivilinna@mbnet.fi, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753167AbYHSMu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 08:50:59 -0400
In-Reply-To: <20080817.235237.24119245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> In fact, as I look at how TBF and NETEM want to use ->requeue() they
> could just the same implement it using my suggested alternative for
> ->requeue() which is just an SKB list ala gso_list hung off of the
> qdisc.

For TBF at least its requeue is actually a bit more sophisticated.
For example, if you hang a prio qdisc off a TBF, then when the
packet is requeued into the prio, the next time TBF dequeues it,
it may get a different packet (of a higher priority).

If you stick it to a list without requeueing, then packets of a
higher priority won't be able to jump the queue anymore.

It might be possible to rewrite TBF to not use requeueing, after
all HTB does it all without requeueing.  However as it stands,
TBF does need it.

I haven't followed this thread closely so what is the main problem
with requeueing (apart from being abused by things like LLTX drivers
and/or NETEM, nothing other than qdiscs like TBF should use it)?

Another possibility would to replace requeue by a peek+force_dequeue
interface, where you can peek at the next packet, and you could then
dequeue that particular packet if you're satisfied.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
