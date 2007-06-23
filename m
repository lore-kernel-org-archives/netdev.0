From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 22:18:44 +0300
Message-ID: <200706232218.50100@auguste.remlab.net>
References: <OF8A941F0F.60C57774-ON88257303.0064A759-88257303.006782B8@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4287948.yUG4r4Y1g1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: cananian@gmail.com, "C. Scott Ananian" <cscott@laptop.org>,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:3199 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbXFWTSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 15:18:52 -0400
In-Reply-To: <OF8A941F0F.60C57774-ON88257303.0064A759-88257303.006782B8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4287948.yUG4r4Y1g1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le samedi 23 juin 2007, David Stevens a =E9crit :
>         This doesn't say that unauthenticated packets must be
> delivered, and I don't think the portability of an RDNS daemon is an
> issue. But even if you really wanted to run the same code on a
> non-Linux machine, it just means that your daemon code would have to
> do its own authentication.
> Reading /proc or netlink with packet formats you've defined to get
> this information is not more portable to non-Linux machines, right? I
> don't see any issue here. If an application is relying on the ability
> to see forged packets for portability reasons, it's probably not an
> application you want running on your machine. :-)

It so happens that the very userland applications that are currently=20
using raw ICMPv6 sockets to see RAs *DO* want to see them all. As far=20
as I know, they are all monitoring softwares (radvdump from radvd,=20
rdisc6 from ndisc6, and probably scapy as well) where you do want to=20
see "problematic" packets.

All in all, this would break well-behaved standard-abiding userland=20
applications...

> > The userspace DNS configuration daemon might need to be started
> > later than the kernel autoconf - another issue that needs help from
> > the kernel.
>
>         Easily done; the init scripts are what bring the interfaces
> up in the first place, so start the daemon before those run. Adding
> an entry in inittab so it'll be automatically restarted if it dies is
> also a reasonable thing. RA's are resent periodically, and they can
> be lost anyway, so not the end of the world if you miss one, either.

What about NFS root? the network interface will already be up before=20
even the real init gets started, let alone the userland RDNSS daemon.

"resent periodically"... at a default rate of one every 10 minutes! I=20
surely hope your desktop boots up faster than that. Besides, some links=20
do not have unsolicited advertisements at all (I have seen such a PPPoA=20
link for instance). An ugly kludge would be to send a RS from userland,=20
but that's not so great considering routers are rate-limiting their=20
RAs.

The only way is for the kernel to remember "something" about the last=20
processed RA. That disqualifies raw ICMPv6 sockets.

=2D-=20
R=E9mi Denis-Courmont
http://www.remlab.net/

--nextPart4287948.yUG4r4Y1g1
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iEYEABECAAYFAkZ9choACgkQw+xtvt1tEr0hEQCeKsliHkdo/Atb8+eqr18SZyCF
fPQAoKnMVMFwYR5ao/1FNEpVn2vfBkXi
=fP4i
-----END PGP SIGNATURE-----

--nextPart4287948.yUG4r4Y1g1--
