From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 14:54:24 +0100
Message-ID: <1195998864.4149.229.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
	 <1195912176.4149.194.camel@johannes.berg>
	 <20071124141319.GA27819@gondor.apana.org.au>
	 <1195938799.4149.197.camel@johannes.berg>
	 <20071125014446.GA32104@gondor.apana.org.au>
	 <1195988428.4149.225.camel@johannes.berg>
	 <20071125112251.GA10039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-m7xv50T2dh5hXEGhr2kK"
Cc: dsd@gentoo.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38170 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbXKYNym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 08:54:42 -0500
In-Reply-To: <20071125112251.GA10039@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-m7xv50T2dh5hXEGhr2kK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Not sure. On the one hand, yeah, that's something we should probably do=
,
> > on the other hand this will suck because for most drivers either nothin=
g
> > needs to be done or the fixup is trivial. I suppose we should do this
> > but stick in a WARN_ON_ONCE() or something, at least with mac80211 debu=
g
> > enabled.
>=20
> I don't see how you can get a WARN_ON to work when you're expecting
> there to be unaligned packets from time to time as the hardware
> header changes.

Well if the hardware header changes and the hardware is dumb enough not
to do padding I'd expect the driver to fix that up so I don't penalise
hardware that gets it correct.

> > Also, we do plan to run these things on rather smallish embedded device=
s
> > like APs that receive a lot of frames from many stations, and with 11n
> > we're pushing speeds up by quite a bit. I'm wary of putting more code
> > into the generic receive path.
>=20
> Well you don't have a choice if the hardware header is really
> unpredictable.  It's either that or we go and modify the entire
> IP stack which penalises all the high-speed Ethernet NICs that
> already get the alignment correctly.

But I do have a choice where to fix it up and I'd prefer the drivers to
do it where necessary. For that, the warning would work because it'd
show driver authors that they need to fix something.

> Here's an idea.  Even if you can't predict the header length of
> all packets, can you at least predict the header length of the
> majority of data (ones carrying IP etc.) packets?
>=20
> If so then you can do the skb_reserve based on that and the fix-up
> in the wireless core would be minimised.
>=20
> Since I know next to nothing about the wireless transport layer,
> one of you experts will need to tell me whether such a prediction
> could work :)

Hmm. I don't think so. Take an AP for example. It gets a lot of packets
from stations. Now, if you're not QoS capable then all is well. But i
you are and some stations are as well then all those stations send QoS
packets (+2 bytes). Or take an AP connected via wireless (WPS), WPS has
+6 bytes so I get all incoming upstream traffic with such unaligned
headers.

johannes

--=-m7xv50T2dh5hXEGhr2kK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0l+j6Vg1VMiehFYAQLf0g/9H/8y5lwJVmjdu2nb2OC4GJM/zdf1Y0F+
KLV6zseHqkm0YcwoXZDoqDhPl3HmeO1ZzWYyqsKyset7s1Vl6nqEYp2YJiYm6Ux9
/+5DXIjaSKRqA2jCn6E/r9aaHB0UUd33VQnAvslqp9kXZNdTh8q1MUwtsUKerbbq
pPR88/BzeDEZXTDq2edzRKxUhVHEyEs3UD12FrXWaHpOLYJNPeUUGHXNnhBs8pBk
4i7ug3ZuyM8euf3GJhPhFZZimoS8tq94ZRkVN4eJGjfkuaxzLXHSI3jrxfLCf+Mu
Hkiz2XS/Fn41rRIUqGY80XwpxHsA4onsHOh2JTKKdY5xNOkIX0I9eQiXXHK4QGDe
V66o7yrsVucpyvRgegZGBVoYiqYr0a8H/fiupOlU+8Z8kqAnakJQ8wWJsRnpSgNR
L0aYoe6f6G/zGExJumPctEKmFFLWPlA5cJkUZ158u94giQmsOXyGQHubcN5vGUyw
06oL6V/v6CR2tSNIhB+w+qjRx88RK6UEMZx6xs5vAcyrpNmoWbM5BsUs0vIvW9L0
WSXzeMsaEJ+V0kSx+UYv0OZW1erkaDRABYFNOdlTdJR9DMhogi9P7KLPBfM4G01n
OLyT/Ae51fhO7Ca72rfShJgFvg56O70bMMhX62F+1ZdxcqfP8KyL8owF+2FaIB1j
to7lWFoxF/Y=
=a54a
-----END PGP SIGNATURE-----

--=-m7xv50T2dh5hXEGhr2kK--

