From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 20:54:34 -0700
Message-ID: <482910FA.1080703@redhat.com>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com> <20080512201341.9ead6a9a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755995AbYEMD53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 23:57:29 -0400
In-Reply-To: <20080512201341.9ead6a9a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton wrote:
>> +	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
>=20
> The fifth assertion triggers with alpha allmodconfig.

This means the simple approach won't work for alpha.

The question is how to solve it?  I suggest the following:

- - define SOCK_NONBLOCK to some value > 16 in include/asm-alpha/socket=
=2Eh

- - add #ifndef SOCK_NONBLOCK around the definition in include/linux/ne=
t.h

- - in sys_socket, sys_socketpair, sys_paccept

   int fflags =3D flags;
   if (SOCK_NONBLOCK !=3D O_NONBLOCK && (flags & SOCK_NONBLOCK)) {
     fflags &=3D ~SOCK_NONBLOCK;
     fflags |=3D O_NONBLOCK;
   }

  and use fflags instead of flags in the places where we pass it on.

This has no costs on platforms other than alpha.

Shall I sent a patch?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkgpEPoACgkQ2ijCOnn/RHQ38gCgyVOI/urGeoIr7CFIfs8C7OyR
I80AniPGGWyxZYUQg0pQlySQHqX/UYlx
=3D5fA2
-----END PGP SIGNATURE-----
