From: Ulrich Drepper <drepper@redhat.com>
Subject: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 08:21:47 -0700
Message-ID: <46F13E8B.4050309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbXISPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 11:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

As a follow up to my question from yesterday on the netdev list what I
think is a real problem.  Either in the kernel or in the POSIX spec.

The POSIX spec currently says this about SOCK_DGRAM sockets:

  If  address is a null address for the protocol, the socket=E2=80=99s =
peer
  address shall be reset.

The term "null address" is not further specified but it will usually be
read to allow the following scenario to work out:

   fd =3D socket(AT_INET6, ...)

   connect(fd, ...some IPv6 address...)

   struct sockaddr_in6 sin6 =3D { .sin6_family =3D AF_INET6 };
   connect(fd, &sin6, sizeof (sin6));

   connect(fd, ...some new IPv6 address...)

This does not work on Linux in the moment.  The socket remains connecte=
d
to the old IPv6 address but the second connect() call does succeed (thi=
s
does not sound OK).  What does work is if the connect call to
disassociate the address uses AF_UNSPEC instead of AF_INET6.


The question is: do people here think this is a problem in the POSIX
spec?  Binding to :: and 0.0.0.0 isn't possible, so maybe the Linux
implementation should allow this?

If you think the POSIX spec is wrong (and can point to other
implementations doing the same as Linux) let me know and I'll work on
getting the spec changed.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8T6L2ijCOnn/RHQRAnSRAJ9sXDGG9OepEQWQInaPgwxCWlaH6wCghqim
ULttg5/lU8c1rSpBnoRCjB8=3D
=3DnGVv
-----END PGP SIGNATURE-----
