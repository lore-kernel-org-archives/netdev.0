From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Sun, 03 Feb 2008 09:57:10 +1100
Message-ID: <E1JLRIM-0008FO-00@gondolin.me.apana.org.au>
References: <20080131185328.GD4671@one.firstfloor.org>
Cc: shemminger@linux-foundation.org, andi@firstfloor.org,
	kaber@trash.net, netdev@vger.kernel.org
To: andi@firstfloor.org (Andi Kleen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51063 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756104AbYBBW5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 17:57:25 -0500
In-Reply-To: <20080131185328.GD4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:
>> Then change TBF to use skb_gso_segment?  Be careful, the fact that
> 
> That doesn't help because it wants to interleave packets
> from different streams to get everything fair and smooth. The only 
> good way to handle that is to split it up and the simplest way to do 
> this is to just tell TCP to not do GSO in the first place.

Actually if we're going to do this I'd prefer you to call skb_gso_segment
instead because that lets us at least bypass netfilter which is one of
the key benefits of software GSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
