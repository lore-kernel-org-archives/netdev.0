From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 03 May 2005 14:31:35 +0400
Message-ID: <1115116295.3414.30.camel@uganda>
References: <20050429144103.A23268@2ka.mipt.ru>
	 <20050503095312.GA29788@gondor.apana.org.au>
	 <1115115502.3414.22.camel@uganda>
	 <20050503101447.GA29973@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wUR+YD3lwNiIhhyNElti"
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503101447.GA29973@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-wUR+YD3lwNiIhhyNElti
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-05-03 at 20:14 +1000, Herbert Xu wrote:
> On Tue, May 03, 2005 at 02:18:22PM +0400, Evgeniy Polyakov wrote:
> >=20
> > It can be compile option - those people who wants asynchronous crypto
> > processing and has appropriate hardware will benefit from that even
> > if theirs general purpose CPU is VIA with PadLock ACE.
>=20
> Well if there were no better options then we'll have to do that.
>=20
> However, I believe that with the right crypto API we should be
> able to have async crypto support without sacrificing synchronous
> performance.

Asynchronous processing will not hurt synchronous pathes in any way.

But in some places we can use async api easily - like block devices
encryption, but for others - like IPsec, there is no ability
to split packet processing and thus even use async api.
How carefully asynchronous API would be created current IPsec code
just can not use it.

> > It looks like several CPUs can not be used for synchronous crypto
> > processing in current IPsec implementation. Using asynchronous
>=20
> That's just an implementation quirk.  I will be addressing that
> soon as part of the xfrm locking clean-up.

That is not enough, as far as I can see, since only one tfm is used
for one transformer state.
Locking changes will allow parallel processing of AH and ESP for
example,
but not two packets from the same flow.

> Cheers,
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-wUR+YD3lwNiIhhyNElti
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCd1MHIKTPhE+8wY0RAvHyAJ97hDiRUjMPNB7sg2i2sSWKre7O+gCeK99w
TahkxWsV6D4GpBuiZbgGn2o=
=sN5I
-----END PGP SIGNATURE-----

--=-wUR+YD3lwNiIhhyNElti--
