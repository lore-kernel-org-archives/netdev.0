From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 04:02:58 -0500
Message-ID: <200801110403.00003.vapier@gentoo.org>
References: <477BD374.6060506@zytor.com> <200801110257.42272.vapier@gentoo.org> <4787221F.3030201@zytor.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2451862.iWDGyk3Tpk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:56425 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbYAKJDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 04:03:02 -0500
In-Reply-To: <4787221F.3030201@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2451862.iWDGyk3Tpk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 January 2008, H. Peter Anvin wrote:
> Mike Frysinger wrote:
> >> all this stuff is ABI constants, and the only reason glibc
> >> doesn't use them is that glibc prefers to use enums over #defines.
> >
> > a proper libc defines things in their headers according to the POSIX
> > specs rather than relying on others to do it for them.  if you want to
> > argue about linux-specific ABI pieces being exported, then you probably
> > have a valid point, but socket.h is hardly that.
>
> Have you looked at it?!!?  It's full of ABI constants, and that's what I
> care about.  POSIX doesn't define, say, AF_UNIX; that's an ABI specific.

i guess it depends on how you define "define" :P.  no, POSIX does not state=
=20
the specific numerical value (ABI) for the define (API), but POSIX does=20
require sys/socket.h provide the macro AF_UNIX.

> > so if the only consumer is klibc and you're against adding these things
> > to it, special case it for __KLIBC__.
>
> No, let's split the header so that there are *no* libc knowledge in the
> kernel.  For the kernel to have knowledge about the specifics of any
> particular libc (klibc, glibc, or any other) is stupid, and that's the
> whole reason we're in this spot to begin with.

we're in this spot at the moment to appease klibc only.  is there any other=
=20
libc out there that is not providing its own complete sys/socket.h but=20
instead relying on linux/socket.h ?  glibc/uClibc rely on linux/socket.h on=
ly=20
for the kernel's definition of sockaddr.

> Again, I don't particularly care about what they're named, but the whole
> point is
>
> 	#include <linux/foo.h>
>
> if you want the subset and
>
> 	#include <linux/bar.h>
>
> if you want the whole set.

i looked more at glibc/uClibc and my primary/original concern (and what i=20
thought what David was raising and you confirming) was that building of gli=
bc=20
was broken and glibc headers would need updates.  that does not seem to be=
=20
the case.  the breakage here is for packages that include both sys/socket.h=
=20
(directly/indirectly) and linux/socket.h (directly/indirectly).

due to the way the network headers depend on each other, this case is trivi=
al=20
to induce.  but i dont think linux/socket.h is any more special than the=20
current retarded conflicts we have between the network headers from the lib=
c=20
(which are required by POSIX and beyond) and the kernel headers.

> No libc specifics, and no feature test macros, which I think we can both
> agree are uglier than hell.

i think in general, all of the network related headers under linux/ are=20
fubared for userspace.

> I thought the naming worked out nicer with <linux/sockaddr.h>

placing the sockaddr definitions into linux/sockaddr.h makes sense.
=2Dmike

--nextPart2451862.iWDGyk3Tpk
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHhzDDAAoJEEFjO5/oN/WBBKIP/2SiqXxOyscyhnYFV1nw7BII
bXSrEECwNepZKTLgDaAjn5qr+rVTtDkNAmg6C//xJ5QUAKeC56Wttb5mZhaJ6ZoU
EnTXHTRhb6iXEasCXZt23m6dO6RWvlGmHDWrJLK/Ek4T2Plze0zesM34JJgg2slC
Emtc0iCkgK4WedVL09IzKtEX482dx6mGGMnN8sxpAdMcvkRmTBQOry3olTB/cNH4
hH2XKEkf2pjlXcRxCzHBoRpxENW7asGMgpwJj+YYkzCtATKTN3z35NJAbfGsudio
+2P43DFeUAqMhs2RnMhGVk6yxluI9NZ0rW6lg4qz2bLoRoRRIJiSz97miTYDzsw0
LxXWCupWLF+iKg84B1cpDhApbKxvjGB3b3VFVaathA9bIQ2cB5TY6U/nYPC6uSc2
ii8a3BEwTgePPtZbGjD09wILoPkTVJ0LuAL5HLS0f/oJeYD5KU7emjDtC2EmYvqH
vdUkbGl9ZqYjiBnbah+ACkl8Zl6D8+TUb1iOHQC8PpK0EYJCkqG7mwJH+SkabyPZ
PselpAbX1gp5FXQ1DVZcEEbp20/Q3ZQRuzL+OcZFvCIK+a8I1YZX1dGzICtS6tu+
WvK4WhT/DTaKTkyJX74EsBJlhs7LiOM1R7Mf4aCAmIP3UiLSg680QZTJVpwl0hrC
o6xG41ENeFg/wTE1QBSq
=Lwup
-----END PGP SIGNATURE-----

--nextPart2451862.iWDGyk3Tpk--
