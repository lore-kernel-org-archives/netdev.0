From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 19:10:25 +0800
Message-ID: <20100329111025.GA23927@gondor.apana.org.au>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi> <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52775 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755233Ab0C2LKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:10:32 -0400
Content-Disposition: inline
In-Reply-To: <4BB082B8.9030400@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 01:36:40PM +0300, Timo Ter=E4s wrote:
>
>>> We can still drop the locking, as ->dead can be made atomic_t.
>>
>> No it doesn't need to be atomic, reading an int is always atomic.
>
> The only reason why it needs to be atomic is because of
> xfrm_policy_kill() which writes '1' and checks if it was zero
> previously. Since the idea is to get rid of the policy lock, we
> can turn ->dead flag to atomic_t and use atomic_xchg for that.
> Otherwise it would be ok to have it as just regular int.

I don't see the point.  As long as the data paths do not take
the lock changing this doesn't buy us much.  You're still making
that cacheline exclusive.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
