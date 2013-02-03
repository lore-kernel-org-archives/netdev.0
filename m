From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: assigning an entire subnet of addresses to an interface
Date: Sun, 3 Feb 2013 22:45:45 +0100
Message-ID: <DUB107-W70CD0C5839AA44142F48CED020@phx.gbl>
References: <20130203205124.GA13738@aldebaran.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <david+ml@madore.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s31.dub0.hotmail.com ([157.55.2.106]:24882 "EHLO
	dub0-omc4-s31.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754048Ab3BCVwC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 16:52:02 -0500
In-Reply-To: <20130203205124.GA13738@aldebaran.madore.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The feature you are looking for is called "Transparent proxy support" o=
r
TPROXY, and is in the kernel since 2.6.28.

This allows an application to bind to any address and handle that traff=
ic.

One of the applications supporting this feature is HAproxy:
http://cbonte.github.com/haproxy-dconv/configuration-1.5.html#5-transpa=
rent





> Date: Sun, 3 Feb 2013 21:51:24 +0100
> From: david+ml@madore.org
> To: netdev@vger.kernel.org
> Subject: assigning an entire subnet of addresses to an interface
>=20
> Dear list,
>=20
> Is there a way to assign an entire subnet of (typically IPv6)
> addresses to an interface?  For example, I'd like to assign the entir=
e
> 2001:db8:f00f::/48 prefix to eth42 without actually running 2^80
> separate "ip addr add" commands.
>=20
> I'm aware that (with sufficiently recent kernels) one can do this:
>=20
> ip -6 route add local 2001:db8:f00f::/48 dev lo
>=20
> - which will cause packets received for any address in this subnet to
> be handled locally.  But that doesn't really answer my question,
> because this does not allow local processes to bind to any desired
> address in the subnet (e.g., running "socat
> 'TCP6-LISTEN:9876,bind=3D[2001:db8:f00f::3141:5926]'" fails with
> EADDRNOTAVAIL).
>=20
> Now apparently Linux _does_ have features which allow a process to
> bind to any desired address in a subnet, since this is the case for
> the IPv4 127.0.0.0/8 standard loopback (I can run "socat
> 'TCP-LISTEN:9876,bind=3D[127.1.2.3]' -" without error).  In a na=EFve
> move, I tried to reproduce the output of ip addr show for the
> 127.0.0.0/8 subnet as input, but failed (there's an extra word "lo" i=
n
> the output that ip does not allow back as input).  Is this because
> this subnet is really magical to the kernel, or because ip input
> parsing is incomplete, or for some other reason?
>=20
> If the feature is not presently available in Linux, is there some hop=
e
> that it eventually will be?  How hard would it be to add it?
>=20
> Thanks in advance,
>=20
> --=20
>      David A. Madore
>    ( http://www.madore.org/~david/ )
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
 		 	   		  