From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 14:51:26 +0300
Message-ID: <4A30EFBE.6080106@iki.fi>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net> <4A30D9AA.1020004@iki.fi> <20090611105638.GA2085@gondor.apana.org.au> <4A30EAAA.4070907@iki.fi> <20090611113709.GA2545@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:57410 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZFKLvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:51:23 -0400
Received: by ewy6 with SMTP id 6so1938383ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 04:51:24 -0700 (PDT)
In-Reply-To: <20090611113709.GA2545@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jun 11, 2009 at 02:29:46PM +0300, Timo Ter=E4s wrote:
>> I guess this is easy for point-to-point tunnels. But how about the
>> multipoint gre tunnels? The needed_headroom can vary on destination
>> basis depending on if they are NATted or not, and on the cipher/hash
>> used.
>=20
> I don't think we need to worry about NAT, well at least we don't
> worry about it on the normal path :)

It affects if ESP or UDP-over-ESP encapsulation is used. This can
vary on destination IP basis. This different needed_headroom size.
This the case only for multi-point tunnels. But yes, we don't need
to worry about it, it just one factor that can affect what the
actual needed_headroom can end up being.

>> Can we change the needed_headroom on-the-fly? Increase it when ever
>> we encounter a larger path? But this also means some packages would
>> get extra headroom allocated.
>=20
> Just make it the maximum.  It's OK to have extra head space.
> If the head space is huge then you've got bigger problems than
> wasted memory :)

I guess so. The difference is not too many bytes. Is it ok to just
change the dev->needed_headroom from xmit routine?

- Timo
