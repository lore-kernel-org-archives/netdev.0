From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Sun, 20 Jan 2013 19:54:47 -0500
Message-ID: <201301201954.51109.vapier@gentoo.org>
References: <201301161205.04502.vapier@gentoo.org> <50F95B0A.1090205@linux-ipv6.org> <50F95DF3.7080602@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6316602.foUSqU4aQs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Carlos O'Donell" <carlos@systemhalted.org>,
	David Miller <davem@davemloft.net>, libc-alpha@sourceware.org,
	bhutchings@solarflare.com, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, schwab@suse.de
To: Pedro Alves <palves@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F95DF3.7080602@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6316602.foUSqU4aQs
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Friday 18 January 2013 09:36:35 Pedro Alves wrote:
> On 01/18/2013 02:24 PM, YOSHIFUJI Hideaki wrote:
> >>>> It's simple enough to move all of the __GLIBC__ uses into
> >>>> libc-compat.h, then you control userspace libc coordination from one
> >>>> file.
> >>>=20
> >>> How about just deciding on a single macro/symbol both the
> >>> kernel and libc (any libc that needs this) define?  Something
> >>> like both the kernel and userland doing:
> >>>=20
> >>> #ifndef __IPV6_BITS_DEFINED
> >>> #define __IPV6_BITS_DEFINED
> >>> ...
> >>> define in6_addr, sockaddr_in6, ipv6_mreq, whatnot
> >>> #endif
> >=20
> > Hmm, how should we handle future structs/enums then?
> > For example, if I want to have in6_flowlabel_req{} defined in
> > glibc, what should we do?
>=20
> Include the glibc header first?  Or is this some other
> use case?
>=20
> The point wasn't that you'd have only one macro for all
> structs/enums (you could split into __IPV6_IN6_ADDR_DEFINED,
> __IPV6_SOCKADDR_IN6_DEFINED, etc.) but to have the kernel
> and libc agree on guard macros, instead of having the kernel
> do #ifdef __GLIBC__ and glibc doing #ifdef _NETINET_IN_H.
>=20
> But as Carlos says, the devil is in the details, and
> I sure am not qualified on the details here.

i shipped some kernel header versions in Gentoo where the linux network=20
headers would include the C library's header (as defined by POSIX) so the=20
structs that were the same would only come from glibc.  the only reported=20
breakage was due to defines that the kernel provided but glibc did not.
=2Dmike

--nextPart6316602.foUSqU4aQs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ/JHaAAoJEEFjO5/oN/WBUr4QAILaTm3EUqS154DTDuZSjwq/
RF5BF+k04XBwsbMudP0gb4pYLJNUxOdYcKN4HvmqIwOBDftKYt2D4EmCHMBDiMnN
2/KMODXhoQHXk2cH3T0f3O64R95xyAoLTstN1yOf4daSJsj964nQ4k6s9PROWU81
OApkodMcbVSuXCLiQpJC1zgbZp2z9klweZKdGEdIONjnChGhN8yAGfqKEtrQLIq3
BujiVjDIDwYDCJeLed17n6okGnr71YELRcpJuk6hYwNa4HFJ+7lF/zaNEl/k/28J
dYGDsGwnCkrAdgPYvm4lr3uajoR5F13wsAADuK3R7qzOlj3whiG+H2NcX8ERQX1B
6PH5A5LPyueXBJ9GbSKakXxML3eGf+Z3kHwK8QL4ZU4PddBw6QbPXxfeiFleAfTg
SDsRPDXxxISmOMDMdsqw/1CoErxf8/dND8r58wsHdBEVXeXNDAlo2M58Z0KTK+SV
+u4/YAPhiq5hVmamdj7YlRqtkenVDuKTKQpnttPB+S7++iU2x9oFHuL9drcMhiuW
X7q8KPpCtlzvbSZHMwtnyLCem8qEKaNPHYulPa1GGlNQ6VADxYL/p9rFK7oI7iSY
tcqIk0wY4/faM70oiMO4kpmzIpnhJgoPv+1zhdyHyvuegBMWI7YI9Mmdz8GtiPoz
eR+4W34f9I7rixpeblxG
=NEGe
-----END PGP SIGNATURE-----

--nextPart6316602.foUSqU4aQs--
