From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 08:32:29 +0800
Message-ID: <20100319003229.GB20227@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54583 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751428Ab0CSAca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 20:32:30 -0400
Content-Disposition: inline
In-Reply-To: <4BA27F72.40901@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 09:30:58PM +0200, Timo Ter=E4s wrote:
>
>>> I don't see why we can't maintain the policy use time if we did
>>> this, all you need is a back-pointer from the top xfrm_dst.
>>
>> Sure.
>
> Actually no. As the pmtu case showed, it's more likely that
> xfrm_dst needs to be regenerated, but the policy stays the
> same since policy db isn't touched that often. If we keep
> them separately we can almost most of the time avoid doing
> policy lookup which is also O(n). Also the currently cache
> entry validation is needs to check policy's bundles_genid
> before allowing touching of xfrm_dst. Otherwise we would have
> to keep global bundle_genid, and we'd lose the parent pointer
> on cache miss.

A back-pointer does not require an O(n) lookup.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
