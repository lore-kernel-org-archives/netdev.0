From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Wed, 16 Jan 2013 14:29:30 -0500
Message-ID: <201301161429.33814.vapier@gentoo.org>
References: <50F6B761.8070106@linux-ipv6.org> <201301161205.04502.vapier@gentoo.org> <20130116.135744.697469565804508454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1598368.kUgqzcCjIn";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org, bhutchings@solarflare.com,
	yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, schwab@suse.de, carlos@systemhalted.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130116.135744.697469565804508454.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1598368.kUgqzcCjIn
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 16 January 2013 13:57:44 David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> > certainly true, but the current expectation is that you don't mix your
> > ABIs. if you're programming with the C library API, then use the C
> > library headers. if you're banging directly on the kernel, then use the
> > kernel headers.  not saying it's a perfect solution, but it works for
> > the vast majority of use cases.
>=20
> This isn't how real life works.
>=20
> GLIBC itself brings in some of the kernel headers, as do various library
> headers for libraries other than glibc.
>=20
> So you can get these conflicting headers included indirectly, and it is
> of no fault of any of the various parties involved.

the headers glibc includes tend to be pretty stand alone specifically so th=
at=20
it doesn't matter

> We have to make them work when included at the same time somehow, and
> this is totally unavoidable.

"them" is vague.  saying that every kernel header has to be usable in the s=
ame=20
compilation unit as every C library header regardless of order is unrealist=
ic=20
(at least it is today).  there are cases where they define the same structu=
re=20
different because the structure as the C library expects is different from =
what=20
the kernel syscall expects.  you could avoid that on the kernel side by giv=
ing=20
them all prefixes (like __kernel_), but that didn't seem entirely palpable =
to=20
the kernel folks.  i couldn't even get them to remove crap that breaks non-
glibc C libraries (e.g. uapi/linux/stat.h -- looks like someone inadvertent=
ly=20
fixed uapi/linux/socket.h finally).

for many networking headers, the C library will provide enums & defines whi=
le=20
the kernel only provides enums.  including the kernel after the C library o=
ne=20
leads to parsing errors as the defines expand in the enum and kill it.  lik=
e=20
linux/in.h and netinet/in.h and IPPROTO_*.
=2Dmike

--nextPart1598368.kUgqzcCjIn
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ9v+dAAoJEEFjO5/oN/WBgWsP/1/PhYIR7pFEd8dCtDAUr3ck
tQagjwdBvkPaw5uneqVoPTywCy4tvvK0Oqh0HyYPyE0PNjUwQzvdi7jgJPye5omZ
A7OtTqULytOvjtPYEwOEB+aCQk43jzuL8gCrFTWYhDwd4vZqFcmlsLAAwXa5YCM3
mRON4PEZ8mcEpANCfoJ6AIpQtVKIssLisBnUmgMFOL3G4SVHrRDWHvXMsqM6dsBt
IsZGPlnPEIJuAIfELuJP4U6aM8wWdMFhfKJ7OOsAuzKALCXzAVYybAWKvOc9hHTN
mMa+hj/G5b4hY8yJSx0O9vvdJJaXYkIBQt6wFBD8V28R84/xsYXR79cflCBuQynj
A/+F0HOs25SpMqeavMZ2ufRwD2JmaMnfpTwXC7KXA6inBD4bv4lP4TbjJPZYxr1M
R3I9Xb8O2NaYxL/6w7v4scND1rVy/c+0j08r0bDpthf4kbhvKVhoupUJ/dt6GwMU
ctg/2RTLQXnSYc5rp4e6tDSshKEBbBNPqDF5O4EsjM1trPQ+Ae8sqW2w7E+kk0V/
EBmUYWiwvmZOzTnVnP82jKGge253S4uDX+9iu6/Cofxeo9ikNg3DUqURhKTCViIr
S4Oz5gloxr4TguX+aEmpP2Ro3ALFYsRKhd0l1HtKFwuZoe0ayOMZLfkIjaGZpWDl
mU4pBlpF2fi3VUl+8d8c
=I0im
-----END PGP SIGNATURE-----

--nextPart1598368.kUgqzcCjIn--
