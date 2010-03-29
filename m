From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 20:11:24 +0800
Message-ID: <20100329121124.GA24470@gondor.apana.org.au>
References: <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi> <20100329115701.GA24367@gondor.apana.org.au> <4BB0970E.7060405@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47146 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752312Ab0C2MLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:11:31 -0400
Content-Disposition: inline
In-Reply-To: <4BB0970E.7060405@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 03:03:26PM +0300, Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> I'm not talking about the flow cache.  The current flow cache
>> code doesn't even take the lock.
>>
>> I'm talking about the other places that you have to convert in
>> order to make this into an atomic_t.
>
> Did you check the other places?
>
> All other places do:
>  fox x policies:
>    lock(x)
>    pol_dead |=3D x->walk.dead;
>    unlock(x)
>  if pol_dead
>    abort
>
> or similar.
>
> And some cases don't even bother to lock the policy currently
> when reading walk.dead.
>
> All of the code treats the walk.dead as a hint. It does not need
> strong synchronization with a lock.

Well then converting it to an atomic_t is completely pointless.
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
