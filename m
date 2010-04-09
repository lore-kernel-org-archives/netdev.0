From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 09 Apr 2010 11:30:49 +0300
Message-ID: <4BBEE5B9.2060509@iki.fi>
References: <20100409080907.GA2029@gondor.apana.org.au> <4BBEE144.8070600@iki.fi> <20100409082239.GA2194@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:39806 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab0DIIau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:30:50 -0400
Received: by ewy20 with SMTP id 20so1248524ewy.1
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 01:30:48 -0700 (PDT)
In-Reply-To: <20100409082239.GA2194@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Apr 09, 2010 at 11:11:48AM +0300, Timo Ter=E4s wrote:
>> It's still really misleading to have generic function that does not
>> do the expected thing based on some config. Compiler should know
>> how to optimize the for loop away if it's being called with fixed
>> array size.
>=20
> But the compiler doesn't know because your patch makes it an
> array unconditionally.
>=20
> The SUB_POLICY stuff was a hack from the very start, but at least
> you could compile it out previously.  Now it'll pollute things
> regardless of the configuration.

It has been array all along. The only difference was that only
the first element was used if SUB_POLICY was not defined.

I still think xfrm_pols_put should do always what the function
name says it's doing.

If we want to further optimize non-SUB_POLICY stuff, we should
probably make XFRM_POLICY_TYPE_MAX =3D 1 and arrange rest of code
so that the compiler can optimize things properly.

But the fact is, that in the new code we need to do conditional
xfrm_policy_put depending on if we had per-socket or global policy
which we matched. Thus we either end up with "if (x)" or the
inline functions for loop's implicit test. Or do you have better
ideas how to avoid that?
