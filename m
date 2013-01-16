From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Wed, 16 Jan 2013 12:28:39 -0500
Message-ID: <201301161228.42592.vapier@gentoo.org>
References: <50F2FF1B.3020708@mageia.org> <201301161205.04502.vapier@gentoo.org> <1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3697423.Mc9bZ6SUye";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>,
	Thomas Backlund <tmb@mageia.org>,
	Eric Blake <eblake@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, David Miller <davem@davemloft.net>, schwab@suse.de,
	carlos@systemhalted.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3697423.Mc9bZ6SUye
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 16 January 2013 12:10:11 Ben Hutchings wrote:
> On Wed, 2013-01-16 at 12:04 -0500, Mike Frysinger wrote:
> > On Wednesday 16 January 2013 10:47:12 Ben Hutchings wrote:
> > > On Wed, 2013-01-16 at 23:21 +0900, YOSHIFUJI Hideaki wrote:
> > > > Cong Wang wrote:
> > > > > (Cc'ing some glibc developers...)
> > > > >=20
> > > > > Hello,
> > > > >=20
> > > > > In glibc source file inet/netinet/in.h and kernel source file
> > > > > include/uapi/linux/in6.h, both define struct in6_addr, and both a=
re
> > > > > visible to user applications. Thomas reported a conflict below.
> > > > >=20
> > > > > So, how can we handle this? /me is wondering why we didn't see th=
is
> > > > > before.
> > >=20
> > > [...]
> > >=20
> > > > This is not a new issue.  In addition to this,
> > > > netinet/in.h also conflits with linux/in.h.
> > > >=20
> > > > We might have
> > > >=20
> > > >  #if !defined(__GLIBC__) || !defined(_NETINET_IN_H)
> > > > =20
> > > >  #endif
> > > >=20
> > > > around those conflicting definitions in uapi/linux/in{,6}.h.
> > >=20
> > > This only solves half the problem, as <netinet/in.h> might be included
> > > after <linux/in.h>.  Also, not all Linux userland uses glibc.
> >=20
> > certainly true, but the current expectation is that you don't mix your
> > ABIs.
>=20
> Whose expectation?  Which ABIs are being mixed?

the kernel's view of the world and the C library's view of the world.  ther=
e=20
is a lot of overlap, but it's the C library's job to provide a POSIX compli=
ant=20
interface (and then some).

obvious examples:
 - the stat structures are not the same and require translation
 - ptrace structures are not the same and you really need to use the C lib =
one
 - the readdir function is completely different

but to this specific question, if you're calling the kernel's network funct=
ions=20
directly, then you need to include the kernel's headers for its definition =
of=20
how things are passed.  if you're calling the C library's network functions=
,=20
then use the C library's headers.

> > if you're programming with the C library API, then use the C library
> > headers. if you're banging directly on the kernel, then use the kernel
> > headers.  not saying it's a perfect solution, but it works for the vast
> > majority of use cases.
>=20
> In practice most C programs for Linux will use a mixture of thinly
> wrapped system calls and higher-level APIs from the C library, and never
> really call the kernel directly (as that requires inline assembler).
> Userland programmers will work around this historical mess by tweaking
> the #include order or splitting source files.  But they shouldn't have
> to.

if you're not calling the kernel directly, why are you including the kernel=
=20
headers ?  what is the problem people are actually trying to address here (=
and=20
no, "i want to include both headers" is not the answer) ?
=2Dmike

--nextPart3697423.Mc9bZ6SUye
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ9uNKAAoJEEFjO5/oN/WBTpMP/3kHM+2YwoSb8NBODwdeuCHd
8oXI2DdH1qKuTP8Z7jA3f4sTFrQAEfQlINnVTOp4Ac5D//S3SH38YV3UV7t0kho5
fS6wfJYMjvAKHzunDzf/trHsb/hrZqddy5AYk5NTCjNyiq3L7SBbWgwa3TLpUoH7
DYJnpF5PB8KnLikhLIrYSpeQwow84oaJPbS4hJ9OnFoBzB5aUilJ69HDUG55l76z
hXfcgLzuhdBL4DT0ZgTzTgf9KMlnkGKUuHdEIgg8HqkPgKj0YEq8rdF1foiJ0GnO
E2ifBqhPMSTTEvLuqXIbdSed0KQdnkfpWdFlpeqHS3UQMu2tDQfgq3Wj7Fvz/MsM
+DqtPRiTaW8QRYtPIE7sNjpG7RqPHWqgnaVRDjlK4F/92fOvgMRjQ57bDwAn2yXc
vc92nGN7Nn9DWLdkSCec9hEdXwE5/2/MQDvyTnKPmA87TTHigg42+1l9wDQefm8/
8Tdw9RfJ1BbRB8cmUEIypu3Jcu444OPD4KJTi4w5tH4bS/rJneuTx/pkt954qn06
oEKQ31ibeJtjoTYCTwo7TK6akR99zgudrxzMqhEN7QgrWi1M9xTtvQw87+g3kANx
dzWtYQ2R/Yv0mzQnfLc1UbKInFSoXK4I4UVo8sX/kzFn9vlyw5R2aeHSSaXDPJti
3A3pnV5jw1qUQvOXvdud
=v4tC
-----END PGP SIGNATURE-----

--nextPart3697423.Mc9bZ6SUye--
