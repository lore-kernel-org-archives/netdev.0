From: Harald Welte <laforge@gnumonks.org>
Subject: [BUG 2.6.18] unaligned access in ipvv6_rcv, nf_ip6_checksum, tcp_error, __ipv6_addr_type, fib6_lookup_1
Date: Sat, 30 Sep 2006 22:20:40 +0200
Message-ID: <20060930202040.GF1083@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/unnNtmY43mpUSKx"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <sparclinux-owner@vger.kernel.org>
To: sparclinux@vger.kernel.org
Content-Disposition: inline
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/unnNtmY43mpUSKx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I've just built 2.6.18 on a sparc64 box (Ultra 5) using gcc-3.3.5
(debian woody).  After booting the kernel, I get tons of unaligned
access messages related to various bits of the IPv6 code:

Kernel unaligned access at TPC[10022cf0] ipv6_rcv+0xb8/0x320 [ipv6]
Kernel unaligned access at TPC[10023800] __ipv6_addr_type+0x8/0x140 [ipv6]
Kernel unaligned access at TPC[1002fd64] fib6_lookup_1+0x2c/0x120 [ipv6]
Kernel unaligned access at TPC[10093878] tcp_error+0x40/0x2c0 [nf_conntrack]
Kernel unaligned access at TPC[1004ce54] nf_ip6_checksum+0x13c/0x1c0 [ipv6]
Kernel unaligned access at TPC[1004ce58] nf_ip6_checksum+0x140/0x1c0 [ipv6]
Kernel unaligned access at TPC[1004ce60] nf_ip6_checksum+0x148/0x1c0 [ipv6]

As I'm not really familiar at all with sparc assembly, the usual "look
at objectdump, try to see what it does, look at corresponding source
code" strategy doesn't work for me in this case.

There could be 7 different bugs, but I think it's more likely that some
common data structure is misaligned and thus causes unaligned accesses
all over the place.

I've put the ipv6.ko and nf_conntrack.ko modules online at
http://people.netfilter.org/laforge/tmp/2618_bug/

This could be a known issue, but I couldn't find any reference to it on
netdev, sparclinux or via google.=20

Any assistance is appreciated, thanks!

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
We all know Linux is great...it does infinite loops in 5 seconds. -- Linus

--/unnNtmY43mpUSKx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFHtGYXaXGVTD0i/8RAkwOAJ92AcOC9vkGUKfzC5MYe/9Jtz2U2QCbBymP
UcnlV2+uPvsH4HHHdRT8gMw=
=UTn5
-----END PGP SIGNATURE-----

--/unnNtmY43mpUSKx--
