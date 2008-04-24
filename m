From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 07:18:43 -0700
Message-ID: <481096C3.2020206@redhat.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com> <20080424112514.055d8071@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbYDXOTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 10:19:42 -0400
In-Reply-To: <20080424112514.055d8071@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Alan Cox wrote:
> Given we will never have 2^32 socket types, and in a sense this is pa=
rt
> of the type why not just use
>=20
> 	socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, ...)
>=20
> that would be far far cleaner, no new syscalls on the socket side at =
all.

You have a strange sense of "clean" I must say.

I don't think this is a viable approach because it is not about the
range.  People can and do select arbitrary values for those types.
Until a value is officially recognized and registered it is in fact bes=
t
to choose a (possibly large) random value to not conflict with anything
else.  Who can guarantee that whatever bit is chosen for SOCK_CLOEXEC
isn't already used by someone?

Add to this that it's not a complete solution (no such hack possible fo=
r
accept) and I think using a new interface is cleaner(tm).

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIEJbD2ijCOnn/RHQRAnUBAKDFxC7Xkl8Qlo5u7PS8XBx4WrNzRQCgm2Ic
mV6zeglZaTJMn3IuGv3tB60=3D
=3D06jC
-----END PGP SIGNATURE-----
