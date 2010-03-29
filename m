From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 19:57:01 +0800
Message-ID: <20100329115701.GA24367@gondor.apana.org.au>
References: <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:53051 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751762Ab0C2L5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:57:09 -0400
Content-Disposition: inline
In-Reply-To: <4BB09178.8050501@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 02:39:36PM +0300, Timo Ter=E4s wrote:
>
>> Yes, on the read side the lock is a completely different beast
>> compared to atomic_read, but I don't see how you can safely
>> replace
>>
>> 	lock
>> 	if (!dead)
>> 		take ref
>> 	unlock
>>
>> without making other changes.
>
> Because the lock is not needed to take ref.
>
> You can take ref as long as someone else is also holding a
> valid reference.
>
> The flow cache keeps a reference to each object it is holding,
> thus we can always take a reference if we find an object there.
> This is what is being done in the current code, and can be
> still done in the new code.

I'm not talking about the flow cache.  The current flow cache
code doesn't even take the lock.

I'm talking about the other places that you have to convert in
order to make this into an atomic_t.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
