From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 16:25:44 +0300
Message-ID: <200706231625.44825@auguste.remlab.net>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2010888.yzmkLUdRcS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "C. Scott Ananian" <cscott@laptop.org>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:3276 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879AbXFWN6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 09:58:40 -0400
In-Reply-To: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2010888.yzmkLUdRcS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

	Hello,

Le samedi 23 juin 2007, David Stevens a =E9crit :
>         Why not make the application that writes resolv.conf
> also listen on a raw ICMPv6 socket? I don't believe you'd need
> any kernel changes, then, and it seems pretty simple and
> straightforward.

Unfortunately, ICMPv6 raw sockets will not work quite properly here,=20
without modifications. At the moment, such a socket will queue just=20
about any Router Advertisement that is received by the host.

Now, assuming the userland daemon did sanity check the message (properly=20
formatted, source and destination addresses are sane, etc), it needs to=20
know whether the IPv6 kernel stack has "accepted" it or not. It could=20
be that the interface the RA was received on had autoconf disabled at=20
the time the packet showed up, or it could be that the system is=20
currently configured as a router, or it could be that we have a=20
SeND-patched kernel and the RA did not pass authentication checks.

And then, what happens if IPv6 networking has been initialized before=20
init got the chance to start the daemon, for instance root over=20
NFS/IPv6? The RA is lost.

Similarly, the daemon has no way to know when information gathered from=20
an RA becomes invalid. Of course, it can duplicate the lifetime timers=20
in userland, but only the kernel knows if the link has been reset to=20
off and on earlier than lifetime expiration.


Whether parsing RDNSS-in-RA belong in the kernel is irrelevant to me, as=20
the kernel does not provide any interface for userland to do it=20
properly at the moment.

=2D-=20
R=E9mi Denis-Courmont
http://www.remlab.net/

--nextPart2010888.yzmkLUdRcS
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iEYEABECAAYFAkZ9H1gACgkQw+xtvt1tEr3TqwCgzTmaNCpEwj6q+3No0rl2eZDF
MukAoM+SqS+fbasqHrgP8eOT3Q8GPn/2
=dyC+
-----END PGP SIGNATURE-----

--nextPart2010888.yzmkLUdRcS--
