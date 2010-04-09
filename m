From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 9 Apr 2010 16:39:34 +0800
Message-ID: <20100409083934.GA2353@gondor.apana.org.au>
References: <20100409080907.GA2029@gondor.apana.org.au> <4BBEE144.8070600@iki.fi> <20100409082239.GA2194@gondor.apana.org.au> <4BBEE5B9.2060509@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48116 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751401Ab0DIIjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:39:41 -0400
Content-Disposition: inline
In-Reply-To: <4BBEE5B9.2060509@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 09, 2010 at 11:30:49AM +0300, Timo Ter=E4s wrote:
>
> It has been array all along. The only difference was that only
> the first element was used if SUB_POLICY was not defined.

It was an array but prior to your patch it only had a single
element when SUB_POLICY is not defined.  Your patch made it
contain XFRM_POLICY_TYPE_MAX elements unconditionally.

> I still think xfrm_pols_put should do always what the function
> name says it's doing.
>
> If we want to further optimize non-SUB_POLICY stuff, we should
> probably make XFRM_POLICY_TYPE_MAX =3D 1 and arrange rest of code
> so that the compiler can optimize things properly.

Anyway, the fact is prior to your patch SUB_POLICY had a minimal
impact on people who don't like it (like me), and now its effect
is being forced on everyone.

> But the fact is, that in the new code we need to do conditional
> xfrm_policy_put depending on if we had per-socket or global policy
> which we matched. Thus we either end up with "if (x)" or the
> inline functions for loop's implicit test. Or do you have better
> ideas how to avoid that?

Which particular piece of code are you referring to?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
