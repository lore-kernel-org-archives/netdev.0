From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon, 5 Apr 2010 16:44:22 +0800
Message-ID: <20100405084422.GB16788@gondor.apana.org.au>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-2-git-send-email-timo.teras@iki.fi> <20100405083302.GA16636@gondor.apana.org.au> <4BB9A113.30601@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38556 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750895Ab0DEIoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:44:25 -0400
Content-Disposition: inline
In-Reply-To: <4BB9A113.30601@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 11:36:35AM +0300, Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Mon, Apr 05, 2010 at 10:00:21AM +0300, Timo Teras wrote:
>>> @@ -219,33 +222,32 @@ void *flow_cache_lookup(struct net *net, stru=
ct flowi *key, u16 family, u8 dir,
>>> +	flo =3D resolver(net, key, family, dir, fle ? fle->object : NULL,=
 ctx);
>>> +	if (fle) {
>>> +		fle->genid =3D atomic_read(&flow_cache_genid);
>>> +		if (IS_ERR(flo)) {
>>> +			fle->genid--;
>>> +			fle->object =3D NULL;
>>
>> Shouldn't we call fle->object->ops->delete here?
>
> The resolver function releases the old object.

I see.

> It might actually make more sense to pass struct flow_cache_object**
> so the resolver can twiddle the flow_cache_entry's object. Then it'd
> be more explicit that the resolver is replacing entries.

Yes that sounds good.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
