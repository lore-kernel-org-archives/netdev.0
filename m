From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: RFC 3484 support
Date: Tue, 18 Nov 2003 00:59:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB9DF8E.7020509@redhat.com>
References: <200311142345.CAA03631@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200311142345.CAA03631@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

kuznet@ms2.inr.ac.ru wrote:

> Datagram connect() is exactly selection of the addresses, nothing more.

I've now implemented a userlevel-only version of the destination address
selection algorithm in glibc's getaddrinfo.  The cost is 4 additional
system calls per returned address plus potentially more (see below).

The code has also limitation I don't think a userlevel implementation
can overcome:

~ rules 3, 4, and 7 are not implemented.  This info is, afaik, only
  available inside the kernel (if at all)

~ the source address selection also needs the label and precedence
  information.  Therefore the kernel would have to share this
  information.

~ to read the label/preference data more syscalls are needed.  And
  there is the question when to read that info.  Once per program
  run?  What about changes to the policies and programs which run
  for a long time?


I'm OK with having this code I wrote as a backup solution.  But I still
would like to see the kernel supporting it directly.  There are programs
which do a lot name lookups and speed is important.

- --=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/ud+O2ijCOnn/RHQRAu23AKDNzNfum+OQFwt2aJ5IgI87yEJTPACgoikN
TKRhY6Kuu56b22mlh+Cguvs=3D
=3DQ9dl
-----END PGP SIGNATURE-----
