From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Mon, 16 Jan 2012 11:23:02 +0100
Message-ID: <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 janvier 2012 =C3=A0 09:56 +0000, David Laight a =C3=A9crit =
:
> Doesn't this badly overflow W[] ..
> =20
> > +#define SHA512_0_15(i, a, b, c, d, e, f, g, h) \
> > +	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
> ...
> > +	for (i =3D 0; i < 16; i +=3D 8) {
> ...
> > +		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
> > +	}
>=20
> 	David
>=20
>=20

No overflow since loop is done for only i=3D0 and i=3D8

By the way, I suspect previous code was chosen years ago because this
version uses less stack but adds much more code bloat.


size crypto/sha512_generic.o crypto/sha512_generic_old.o
   text	   data	    bss	    dec	    hex	filename
  17369	    704	      0	  18073	   4699	crypto/sha512_generic.o
   8249	    704	      0	   8953	   22f9	crypto/sha512_generic_old.o
