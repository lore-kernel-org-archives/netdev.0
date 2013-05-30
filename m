From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 14:23:00 +0200
Message-ID: <20130530122300.GD2475@ritirata.org>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
 <20130528.233647.1209227470109213894.davem@davemloft.net>
 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
 <20130529194438.GY3333@ritirata.org>
 <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com>
 <20130530114556.GC2475@ritirata.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Ycz6tD7Th1CMF4v7"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, horms@verge.net.au
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:23134 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab3E3MYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:24:54 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Ycz6tD7Th1CMF4v7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 30, 2013 at 01:12:15PM +0100, David Laight wrote:
> > > > > > > I want to use something that will either break the build or
> > > > > > > automatically work if the type changes again.
> > > > > > >
> > > > > > > So something like "X =3D (typeof(X)) ~0U;".
> > > > > >
> > > > > > I think you mean ~(typeof(X))0.
> > > > >
> > > > > Am I wrong or you should cast the value once again, like this:
> > > > >
> > > > > ((typeof(X))~(typeof(X))0)
> > > > >
> > > > > because the ~ operator will implicitly cast the argument to int (=
if I remember
> > > > > correctly).
> > > >
> > > > It will promote to at least int, but that still results in the right
> > > > value and doesn't provoke a warning.  Try this test (with -Wall
> > > > -Wextra):
> > > >
> > > > #include <stdio.h>
> > > >
> > > > #define ALL_ONES(v) (~(typeof(v))0)
> > > > /* #define ALL_ONES(v) (typeof(v))~0U) */
> > > >
> > > > int main(void)
> > > > {
> > > >     char a =3D ALL_ONES(a);
> > > >     unsigned char b =3D ALL_ONES(b);
> > > >     short c =3D ALL_ONES(c);
> > > >     unsigned short d =3D ALL_ONES(d);
> > > >     int e =3D ALL_ONES(e);
> > > >     unsigned int f =3D ALL_ONES(f);
> > > >     long g =3D ALL_ONES(g);
> > > >     unsigned long h =3D ALL_ONES(h);
> > > >     long long i =3D ALL_ONES(i);
> > > >     unsigned long long j =3D ALL_ONES(j);
> > > >
> > > >     printf("%hhx %hhx %hx %hx %x %x %lx %lx %llx %llx\n",
> > > > 	   a, b, c, d, e, f, g, h, i, j);
> > > >     return 0;
> > > > }
> > >
> > > The printf format is masking the high bits for you.
> > > If you change to:
> > > 	printf("%x %x %x %x %x %x %lx %lx %llx %llx\n", ...)
> > > you get different values.
> > > To get the 'expected' values you need casts both sides of the ~
> >=20
> > I tried with
> >=20
> > 19     printf("%x %x %x %x %x %x %lx %lx %llx %llx\n",
> >=20
> > but I still see all FF.
> >=20
> > Somewhere else we have some hidden conversion?
>=20
> Of course - we need to look at the value that ALL_ONES()
> generates in an expression. So the test print needs to be:
> 	printf("%hhx %hhx %hx %hx %x %x %lx %lx %llx %llx\n",
> 		ALL_ONES(a), ALL_ONES(b), ALL_ONES(c), ALL_ONES(d),
> 		ALL_ONES(e), ALL_ONES(f), ALL_ONES(g), ALL_ONES(h),
> 		ALL_ONES(i), ALL_ONES(j));
> which then gives 0xffffffff for the first 4 entries.

It gives all FF for every argument. So, I'm not understanding the problem..=
this
is what Ben wanted to achieve, no?

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--Ycz6tD7Th1CMF4v7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRp0SkAAoJEADl0hg6qKeOQBEP/iBF9sq/EdE3npGrGihR0MBV
7nJ0xo8XgSVLxXp0IBQeb2MqHJdeensrec+bBPyQ1WdONYsSnI3GPmPSIlzCMsW+
gWCK6kDZYOIeezrvSAVEfuEPa9s/yKSwJGaQBzLHxnImelU3EyG6m6J7lpdQQ8G6
TBEczB04iQTU43GhHUyYN+DgLOrHhLiGQ/mPZBJ0BA7UhwG75omrbjrlxeQoRElJ
o9HRcwrc+MI8MRKEmUryZ00/oQoyKQI5fqaejvLBBscedpOd2jkuedUBcyxJXOKa
qlV/Jl2Po79cMebMS9SibuwvXh9EpqAg8B98EuM3tS/xAIMBtvzYAeRP70INi+Vz
QWeJAHxm1rcFgIk5xQqyDAQOcBUiGVBfclbpf3Rl11Uj87n4euYKr+9Tk9o3VQpT
/Z+hwgRamQyzDB+z3270TWiIWzehMDwjTMqoqbpr6VFhzCFDMo6m7rX7B8k3d5GQ
m2/71sJbcA8jamM2ADCK1KnQ6fJU0asa6NAlDkcPwuPGx4is0UK0YXlcJ5ZzXMFb
EVHZRneDD4Jc4MkxNJ4STlKc5E63tr0UdQG9Knq9mdilJmnBGjqYSd8b2i8zTbbP
G5W2C/0zCslFgipHaCp11cjAr8cMbaE5iwjR7uf5dGx5jtdDrm/qXs+c65QZbZkf
6wO3pamn2UHv9WmoEePZ
=CDOh
-----END PGP SIGNATURE-----

--Ycz6tD7Th1CMF4v7--
