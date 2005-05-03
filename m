From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 03 May 2005 14:55:28 +0400
Message-ID: <1115117728.3414.48.camel@uganda>
References: <20050429144103.A23268@2ka.mipt.ru>
	 <20050503095312.GA29788@gondor.apana.org.au>
	 <1115115502.3414.22.camel@uganda>
	 <20050503101447.GA29973@gondor.apana.org.au>
	 <1115116295.3414.30.camel@uganda>
	 <20050503102929.GA30097@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-k9PHOwYCs5KMRHWF2+qk"
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050503102929.GA30097@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-k9PHOwYCs5KMRHWF2+qk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2005-05-03 at 20:29 +1000, Herbert Xu wrote:
> On Tue, May 03, 2005 at 02:31:35PM +0400, Evgeniy Polyakov wrote:
> >
> > Asynchronous processing will not hurt synchronous pathes in any way.
>=20
> It will if you force everybody to go through the asynchronous path
> because you're jacking up the latency.

But if it will not be selected - IPsec users will not be affected.

Using asynchronous crypto processing of course has it's own nitpics,
and although it's value was prooven [1] to be unsignificant, it is
still=20
there.

Current IPsec processing [even if it is UP only] has very strong model
which
always gets the maximum only from synchronous crypto.

If people select asynchronous IPsec processing - they will use=20
_asynchronous_ IPsec processing, and no _synchronous_ pathes will be=20
affected.
Using asynchronous IPsec processing is only usefull with asynchronous
crypto layers, so no need to turn it on if none could be used with
hardware.

Btw, current crypto schema by design is SMP unfriendly - there is
only low-level TFM entity, which=20
1. must be recreated for several CPUs
2. caller must know about how many CPUs are, which TFM to use and so on.

Asynchronous crypto layers allow to hide it using proper API.

I doubt there will be any benfit for existing IPsec schema from several
CPUs without either some crypto processing rewrite
(either by using per-cpu xfrm states or using several tfms per
transformer),
or without using some asynchronous crypto processing schema...


[1] http://www.openbsd.org/papers/ocf.pdf

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-k9PHOwYCs5KMRHWF2+qk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCd1igIKTPhE+8wY0RAreZAJ0UMQ91mhs1Elzjm/pOowLPpTM1KACeMRzi
hzOPWkUIC40JQeseFr15c/k=
=ArHw
-----END PGP SIGNATURE-----

--=-k9PHOwYCs5KMRHWF2+qk--
