From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: Regarding to your linux kernel CL
Date: Wed, 6 Oct 2010 01:04:18 -0700
Message-ID: <AANLkTinuis9vneb44W18jwLZ=KzFJQeVGg-FhGsWgK7-@mail.gmail.com>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
 <4CAC1F20.6070009@iki.fi> <20101006075946.GA5311@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:60685 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758716Ab0JFIEq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 04:04:46 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o9684iUQ025504
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 01:04:45 -0700
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by hpaq3.eem.corp.google.com with ESMTP id o9684OnF024545
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 01:04:43 -0700
Received: by qyk33 with SMTP id 33so4856730qyk.14
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 01:04:43 -0700 (PDT)
In-Reply-To: <20101006075946.GA5311@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have submitted a patch([PATCH] net: Fix sk_dst_check() to reset the
obsolete dst_entry of a socket) for this, please reply to that thread
then.

Thanks,
Chung-yih

On Wed, Oct 6, 2010 at 12:59 AM, Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
> On Wed, Oct 06, 2010 at 10:02:56AM +0300, Timo Ter=E4s wrote:
>>
>> What's the problem here? sk_dst_check not honoring if dst->obsolete>=
0 ?
>> Sounds like the sk_dst_check was buggy in the first place.
>
> Well the problem is that before we changed ip4_dst_check, everything
> worked properly. =A0With IPv6, whenever a route is released, the seri=
al
> number is always updated accordingly. =A0This means that ip6_dst_chec=
k
> will always return NULL when obsolete > 1.
>
> The old ip4_dst_check also satisfied this requirement since it always
> returns NULL.
>
>> Looks like there's still some code around that does not do what the
>> obsolete field has been used for a long time.
>> =A0 obsolete =3D =A00, dst entry is ok
>> =A0 obsolete =3D -1, you need to call ops->check for this entry
>> =A0 obsolete > =A00, this entry is invalid
>>
>> So net/core/sock.c needs fixing. Just if we should change dst_check(=
)
>> too, I'm not sure.
>>
>> Should we fix sk_dst_check to use dst_check(), and dst_check() to ch=
eck
>> for dst->obsolete>0 ?
>
> Yes this should work too. =A0However, I was never totally happy with
> this new dst->obsolete logic which means that we're doing an
> indirect call for every single packet which almost always does
> nothing.
>
> Perhaps we should move the genid/cookie logic into the dst so that
> we can eliminate the dst->check call or at least make it a lot less
> frequent.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
