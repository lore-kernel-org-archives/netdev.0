From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 14:29:46 +0300
Message-ID: <4A30EAAA.4070907@iki.fi>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net> <4A30D9AA.1020004@iki.fi> <20090611105638.GA2085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:44667 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbZFKL3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:29:43 -0400
Received: by ewy6 with SMTP id 6so1921091ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 04:29:44 -0700 (PDT)
In-Reply-To: <20090611105638.GA2085@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jun 11, 2009 at 01:17:14PM +0300, Timo Ter=E4s wrote:
>>> Otherwise we'd need a similar hack in ipip.c too.
>> I was under the impression that as we need to do the route lookup an=
yway
>> we could take advantage of the information available from there full=
y.
>>
>> But yes, your explanation makes perfect sense.
>=20
> I think you're both right :)
>=20
> We should include the IPsec head room here, but also in the
> dev->needed_headroom calculation so that most packets don't
> get reallocated in the first place.

I guess this is easy for point-to-point tunnels. But how about the
multipoint gre tunnels? The needed_headroom can vary on destination
basis depending on if they are NATted or not, and on the cipher/hash
used.

Can we change the needed_headroom on-the-fly? Increase it when ever
we encounter a larger path? But this also means some packages would
get extra headroom allocated.

- Timo

