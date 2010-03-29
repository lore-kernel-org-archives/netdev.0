From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 19:32:25 +0800
Message-ID: <20100329113225.GA24159@gondor.apana.org.au>
References: <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:43607 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750707Ab0C2Lcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:32:33 -0400
Content-Disposition: inline
In-Reply-To: <4BB08D96.8090909@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 02:23:02PM +0300, Timo Ter=E4s wrote:
>
>> I don't see the point.  As long as the data paths do not take
>> the lock changing this doesn't buy us much.  You're still making
>> that cacheline exclusive.
>
> To my understanding declaring an atomic_t, or reading it with
> atomic_read does not make cache line exclusive. Only the atomic_*
> writing to it take the cache line. And since this is done exactly
> once for policy (or it's a bug/warn thingy) it does not impose
> significant performance issue.

I was talking about the lock vs. atomic_xchg in xfrm_policy_kill.
There is practically no difference for that case.

Yes, on the read side the lock is a completely different beast
compared to atomic_read, but I don't see how you can safely
replace

	lock
	if (!dead)
		take ref
	unlock

without making other changes.

> But looking at the code more. The check should not be needed.
> xfrm_policy_kill() is only called if the entry is removed from
> the hash list, which can happen only once.
>
> Do you think we can just change it to unconditionally writing
> to "policy->walk.dead =3D 1;" and be done with that?
>
> Alternatively, we can move the ->dead check to be done while
> holding the hash lock to guarantee no one else is writing
> simultaneously.

See above.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
