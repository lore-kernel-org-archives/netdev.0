From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 02:57:41 -0500
Message-ID: <200801110257.42272.vapier@gentoo.org>
References: <477BD374.6060506@zytor.com> <200801110207.39736.vapier@gentoo.org> <4787164F.9030805@zytor.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9183224.kUD78k5HqU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53645 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbYAKH5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 02:57:44 -0500
In-Reply-To: <4787164F.9030805@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart9183224.kUD78k5HqU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 11 January 2008, H. Peter Anvin wrote:
> Mike Frysinger wrote:
> > oh, sorry, i see what you mean.  i was thinking in terms of crap removed
> > (as that's what i'm after), not crap added (which is what Peter is
> > after).  i hadnt noticed that.  i dont know if it'll break glibc (and
> > really, any other sane libc).  if that is the case, then i think klibc
> > here is the 2nd class citizen to everyone else.
>
> I don't really understand why you insist on using such inflammatory
> language;

it's true.  it is much easier to adapt klibc on the fly than every one else=
=2E =20
klibc is also of significant less importance in the larger open source=20
landscape than glibc or other libc's.  this isnt really inflammatory so muc=
h=20
as fact.

> all this stuff is ABI constants, and the only reason glibc=20
> doesn't use them is that glibc prefers to use enums over #defines.

a proper libc defines things in their headers according to the POSIX specs=
=20
rather than relying on others to do it for them.  if you want to argue abou=
t=20
linux-specific ABI pieces being exported, then you probably have a valid=20
point, but socket.h is hardly that.  imo klibc is being lazy.  you disagree=
=2E =20
here we are.

> Right now, glibc is special-cased.  glibc also tends to be very
> deliberate about its kernel header inclusions.  It wants a subset of the
> available defines, so it can include a subset header.
>
> The reverse is definitely possible too -- all other users (kernel,
> newlib, dietlibc, uclibc, and klibc) can change and leave the current
> state for glibc.

that list is inaccurate.  newlib is generally not used under linux, but of =
the=20
few headers it does use, socket.h is not one of them.

i dont use dietlibc myself as ive found it generally not suitable for much,=
=20
but a quick look through their source code shows linux/socket.h not in use =
at=20
all.

uClibc is the exact reason i started this thread in the first place.  we ha=
ve=20
__GLIBC__ define in place to account for broken code and it's because of=20
things like linux/socket.h that we cannot yet remove it.

glibc has not used the typedefs/defines in question in ages, so they're not=
=20
affected by the things not being available.

that leaves klibc.

> We can special-case the kernel in the above case, but that would involve
> some additional ugliness.

so if the only consumer is klibc and you're against adding these things to =
it,=20
special case it for __KLIBC__.
=2Dmike

--nextPart9183224.kUD78k5HqU
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHhyF2AAoJEEFjO5/oN/WBys4P/jXFh+iwc4PEiYnFmVF4XwwD
YG36DxgL98T77X6IVtzSV6N+Cr5RVG9/ih4qHSGAI7811btPRtSU4edfyLk4T6KN
v/+WV67OhpW2uu+wjbPb3tatfjSQh/itQuFAd17qeohW0nYa928QBu7Yu+f3SDjc
BSgdaRxSd1xLYCzGgnwmvIHaSfaOuOC8oieFnGq3rYxoj5PRn4Yo+5mpYhwTdi7h
6/7f2TgoRudfJbFgZ3Z4AD2L39Zm0MgugGZncdsHtu22zlXPf1mGOPwpfGDOkNBp
C2isOvw3Si6aHtMJXPHAZEa6oVgOWRktT2CXLh79A/rl7iKSgosddILmzo35CzZ+
1Dp5Pz4Ir/PeeOQel+gqyTGaEqOfVgYpIx+egTna0HBT1/rL6KtMOY69gonUMoh3
CbsqpjPwhRq6WNXXjibkI8dRNdGioqOL7qjpSup1LNKTwlXxXgdzRlrm5U4Kh0kI
fdFacYVoO0q7cAgNPW6gxYOg8DtBQC3l7nrCXZ9PP/9+cic9tJhB/RrcpOStlJeC
js1gg15lGYhG14biZpE6+Tb6IuX+V39QxYsNahg9EEJYI6Am7gQ93dYMqZ/TJg8p
M5N/PFzzWw1CpwwUKpivpsvdOquZkSDOoRnKzEoiBOOJM9WmGLJJSg4SfynCsDTu
plfJNnVJtKNAjneMFNkU
=O2Kl
-----END PGP SIGNATURE-----

--nextPart9183224.kUD78k5HqU--
