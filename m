From: Ulrich Drepper <drepper@redhat.com>
Subject: RFC 3484 support
Date: Tue, 11 Nov 2003 17:05:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB18758.8040708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I want to implement RFC 3484 support in getaddrinfo for glibc but there
is the tiny little problem with the source address selection which has
to be solved as part of the destination address selection.

To sort the destination addresses the source address for each of the
addresses returned by getaddrinfo must be determined.  This can be done
in two ways:

1. use the existing kernel functionality and provide an interface to it
   which userlevel can use

2. re-implement routing at userlevel


#2 above has serious problems.  To accurately re-implement the kernels
routing decision making a huge amount of data is needed.  Not only the
routing information, but also transient errors, all the kernel
parameters and flags influencing routines etc.  This is, I'd say,
virtually impossible which would mean an implementation with the source
address selection happening at userlevel would do a bad job in some cases.

So my question is: is there interest in adding support for method #1 to
the kernel?  Could we get a syscall or whatever to pass down to the
kernel a set of addresses (and whatever else is needed) and the kernel
passing back information about the sorted list (either the sorting list
or a transformation description of some sort)?


[I'm not on this list, so please cc: me.  DaveM made me post here.]


- --=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/sYdY2ijCOnn/RHQRAppvAJ9MuBPXJM5tH93mXwRu2prifwo+GACfSjzg
tuMC3yIgcqugevSYvuJpC2g=3D
=3DyEdb
-----END PGP SIGNATURE-----
