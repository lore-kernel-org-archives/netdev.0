From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] give truesize warning when truesize differs
Date: Mon, 05 May 2008 17:22:40 +0200
Message-ID: <1210000960.8245.28.camel@johannes.berg>
References: <1209924728.3655.7.camel@johannes.berg>
	 <1209993080.8245.16.camel@johannes.berg>
	 <20080505150405.GA9626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-WeQ5mSgNimr3XISoXy6U"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47205 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373AbYEEPXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 11:23:45 -0400
In-Reply-To: <20080505150405.GA9626@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WeQ5mSgNimr3XISoXy6U
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 23:04 +0800, Herbert Xu wrote:
> On Mon, May 05, 2008 at 03:11:20PM +0200, Johannes Berg wrote:
> >
> > >  static inline void skb_truesize_check(struct sk_buff *skb)
> > >  {
> > > -	int len =3D sizeof(struct sk_buff) + skb->len;
> > > +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> > > +	int len =3D sizeof(struct sk_buff) + skb->end;
> > > +#else
> > > +	int len =3D sizeof(struct sk_buff) + (skb->end - skb->head);
> > > +#endif
> >=20
> > Umm, is this even correct? Should it check data_len? I seem to get the
> > truesize warning a bit now:
>=20
> It must check data_len.

I figured. Just add it?

johannes

--=-WeQ5mSgNimr3XISoXy6U
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB8mP6Vg1VMiehFYAQK5bRAAjT4rIJNQLSBqE6uFT6MecueqEZUJFep5
CTO/KBdB6nQyVcN7sJtuwRTsruvGxVWazYBWnnN9WafunqBgQ7Qr/4kuKkkMY3h8
0vU3MlxWf6Gq4G3jzDAcpt1iz+JK6kXxuqzqznp5S8+6fxY9sKQVeNm8Xuqm6Lii
7OHAhZTw13wcGsQDHBIMEPpGhBqLbkAVBGuWr7vJuilRLkBxxUMEcZ0t91HCQYQD
2k3BgMZ1jGrMbJVGDeNFx4KEgqoj8RPoTKYUmob85su3TjhJJgb3slD/T3SZvaSb
pAfqa/hs+eFSZNLtaL2VY7+mjL8GIcc54hxi02arua6qxyX80pSeYE3zvo42kahG
aRgl3NO+S0ltQG3mxpbHyDnyjvJAMYZD9FwyElwuwGNa6oOyaPwBGAGDxle4qaHC
gW6jCTWbLNluB8Vh/2nw4bJYpCjmRx+9USNcEqnGeKV5xG58T6knLMW4naB4mb+h
MOsrN9fCCmlk6ErfFdXh0DSAUO6i72/3hkzHAZzhVZ9HEABsargCt22wCO2lqeNL
ZLmLjjzk7EOXijJHahdADmlkNNB4njmiev+fadxlmIOdxtS7vVs4jJwTjH5JuXGS
ZIsfAaoiWp9x6CO8JAqx+m2xD/dbdce5V5m+j8gpH6U/FX3SFoWf5yJ2YevsNaeV
AMmYku5CXgA=
=g7e3
-----END PGP SIGNATURE-----

--=-WeQ5mSgNimr3XISoXy6U--

