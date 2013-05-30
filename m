From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 13:45:56 +0200
Message-ID: <20130530114556.GC2475@ritirata.org>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
 <20130528.233647.1209227470109213894.davem@davemloft.net>
 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
 <20130529194438.GY3333@ritirata.org>
 <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="4ZLFUWh1odzi/v6L"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, horms@verge.net.au
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:37684 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab3E3Lrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:47:51 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4ZLFUWh1odzi/v6L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 30, 2013 at 12:41:03PM +0100, David Laight wrote:
> > > > > I want to use something that will either break the build or
> > > > > automatically work if the type changes again.
> > > > >
> > > > > So something like "X =3D (typeof(X)) ~0U;".
> > > >
> > > > I think you mean ~(typeof(X))0.
> > >
> > > Am I wrong or you should cast the value once again, like this:
> > >
> > > ((typeof(X))~(typeof(X))0)
> > >
> > > because the ~ operator will implicitly cast the argument to int (if I=
 remember
> > > correctly).
> >=20
> > It will promote to at least int, but that still results in the right
> > value and doesn't provoke a warning.  Try this test (with -Wall
> > -Wextra):
> >=20
> > #include <stdio.h>
> >=20
> > #define ALL_ONES(v) (~(typeof(v))0)
> > /* #define ALL_ONES(v) (typeof(v))~0U) */
> >=20
> > int main(void)
> > {
> >     char a =3D ALL_ONES(a);
> >     unsigned char b =3D ALL_ONES(b);
> >     short c =3D ALL_ONES(c);
> >     unsigned short d =3D ALL_ONES(d);
> >     int e =3D ALL_ONES(e);
> >     unsigned int f =3D ALL_ONES(f);
> >     long g =3D ALL_ONES(g);
> >     unsigned long h =3D ALL_ONES(h);
> >     long long i =3D ALL_ONES(i);
> >     unsigned long long j =3D ALL_ONES(j);
> >=20
> >     printf("%hhx %hhx %hx %hx %x %x %lx %lx %llx %llx\n",
> > 	   a, b, c, d, e, f, g, h, i, j);
> >     return 0;
> > }
>=20
> The printf format is masking the high bits for you.
> If you change to:
> 	printf("%x %x %x %x %x %x %lx %lx %llx %llx\n", ...)
> you get different values.
> To get the 'expected' values you need casts both sides of the ~

I tried with

19     printf("%x %x %x %x %x %x %lx %lx %llx %llx\n",

but I still see all FF.

Somewhere else we have some hidden conversion?

Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--4ZLFUWh1odzi/v6L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRpzv0AAoJEADl0hg6qKeOeZsQAIB9yps/j9ttoGVe7kjq7Te1
SxVbdWQFv2+wLoC0ob6QVKZRstI2zsdFY9MpZgcQoSM0DRULw3lwzzDz73XlUVnW
E6okpeX0jxsMZgxE4SYyfsmD+gNWA6q2DKiWgHK4wSdRf2Vl+ruZKKzt4afhCCza
4qv3Lv3PSICQgw7YWr5qS/xFqgeEgb/3sNYDvTVxMZLBVQArzZgcMd9fVUDE9uH7
beiWrtTfQSaqOI3w60sPY563X8d0lmG6o3LdtV1mImCq4qdCYSBGPr0BgkG3GTPH
QkOEIuu5DtGNl1MnyqX5GLjstAXUc6LGtxWXbrM4aPE6sVLPsjFgHOgeaw4Wm10D
2saTfymi0fc7dnDZ/EPcNDLTatwdggo9XVHpQ7hogbh3uFBz/vvlfrQsK/b6NFIP
sOp0ppH7Y7bX1LYLMt5ouGQ35gKd+TyyfGspKDCe3yMTYCaHPNzuyEWxdGa+fGhL
auOPMN6ZkpzodHW0wXL8pm6t1W2K/lrEERmrkpoNKXGezNICaFPROpmZ3RR4jKE1
u9fb6DfCILbRykyWQRzxb4ZLEB44DaPaEg0JeHEmnKfM6jfWbyWZWkd374lBUOX9
7LogCtgy0reFozWkT3sY4RAd7+RGcJekcNZULlMKOOCrXgOKKeG788QkUUAVS3KP
brV/t4ztpuT+xphEqJ6x
=IRZE
-----END PGP SIGNATURE-----

--4ZLFUWh1odzi/v6L--
