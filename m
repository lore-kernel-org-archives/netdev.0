From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Wed, 16 Jan 2013 12:04:56 -0500
Message-ID: <201301161205.04502.vapier@gentoo.org>
References: <50F2FF1B.3020708@mageia.org> <50F6B761.8070106@linux-ipv6.org> <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1512353.NV2mUTysa3";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>,
	Thomas Backlund <tmb@mageia.org>,
	Eric Blake <eblake@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, David Miller <davem@davemloft.net>, schwab@suse.de,
	carlos@systemhalted.org
To: libc-alpha@sourceware.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1512353.NV2mUTysa3
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 16 January 2013 10:47:12 Ben Hutchings wrote:
> On Wed, 2013-01-16 at 23:21 +0900, YOSHIFUJI Hideaki wrote:
> > Cong Wang wrote:
> > > (Cc'ing some glibc developers...)
> > >=20
> > > Hello,
> > >=20
> > > In glibc source file inet/netinet/in.h and kernel source file
> > > include/uapi/linux/in6.h, both define struct in6_addr, and both are
> > > visible to user applications. Thomas reported a conflict below.
> > >=20
> > > So, how can we handle this? /me is wondering why we didn't see this
> > > before.
>=20
> [...]
>=20
> > This is not a new issue.  In addition to this,
> > netinet/in.h also conflits with linux/in.h.
> >=20
> > We might have
> >=20
> >  #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)
> > =20
> >  #endif
> >=20
> > around those conflicting definitions in uapi/linux/in{,6}.h.
>=20
> This only solves half the problem, as <netinet/in.h> might be included
> after <linux/in.h>.  Also, not all Linux userland uses glibc.

certainly true, but the current expectation is that you don't mix your ABIs=
=2E =20
if you're programming with the C library API, then use the C library header=
s. =20
if you're banging directly on the kernel, then use the kernel headers.  not=
=20
saying it's a perfect solution, but it works for the vast majority of use=20
cases.
=2Dmike

--nextPart1512353.NV2mUTysa3
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ9t3AAAoJEEFjO5/oN/WBAYgP/A/n5Xk+zSGfX/nN3Q2TPyCL
d+6D4XPK7QCaPCNJL7g3Rhxcxf2w3KkSiAtuvmLFgPpNtXmKdDbH8Xs+hfms76SF
PJGCHvb0je7v2WESg1pB6rVWN2jbwcZhUMnDxQfaXvXKtjb3KELoFNMq3EZKlsy/
VABNofBuwEGgVGDWJaxIXqoZRhLymLhI1YrygO2WJXeuYcqZIO0uvgaRDon5k7uC
ikc0rst7d08Do2HaS7JUuVKRB/IOtHxleX4tTGiZDQlRMTytrA4jBMuhHNvhZGSf
cKbmaLc+TrjFLNV0pV7i/NEyErFBwjTozJivyv36Dkv0T83Dt8rhl1zwu4Ok8sPu
hmhrjswogTmb2NmdCdcL40Bv/Q/E/SiWiY0u73ptHNzoQfZ4yvJ2c/6nJfzTjaJ5
Pz2wnJO4s6QuTr2/IC7GsH+ofvhxddpccQcL3qQdcwnDTcYwr8knlnjkBRIh10vj
6cWYPUA/ZuVZs2Qes3IowsUHVZ4xTmswPt9c+5jn/UfambkccQUcdrzTRf1ePa8N
NNtlqh578olItOIOEvA5CrlCsqxGMLh0a5HfnPGF5HGCdOnQhvOsq2R8VepeevzQ
r627wklck13cev5V06x59s2XLsbZ7YwF9VY9HH7GZ4zIAF12QN6mmUg8Lo4EQ2Lj
auNbH2ps4uUtje6lBl6R
=0ouB
-----END PGP SIGNATURE-----

--nextPart1512353.NV2mUTysa3--
