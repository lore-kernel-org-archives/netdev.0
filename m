From: "Mario 'BitKoenig' Holbe" <Mario.Holbe@TU-Ilmenau.DE>
Subject: Re: netfilter: marking IPv6 packets sends them to the wrong
 interface
Date: Mon, 24 Jan 2011 18:02:13 +0100
Message-ID: <20110124170213.GB2616@darkside.kls.lan>
References: <20110123122108.GA30305@darkside.kls.lan>
 <4D3D82D1.6050305@trash.net>
 <20110124143518.GA2616@darkside.kls.lan>
 <4D3DA48A.2020605@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7ZAtKRhVyVSsbBD2"
Cc: netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from piggy.rz.tu-ilmenau.de ([141.24.4.8]:59627 "EHLO
	piggy.rz.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753772Ab1AXRCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 12:02:19 -0500
Content-Disposition: inline
In-Reply-To: <4D3DA48A.2020605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7ZAtKRhVyVSsbBD2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 24, 2011 at 05:10:50PM +0100, Patrick McHardy wrote:
> > Yes, disabling the ip6_route_me_harder() call in ip6t_mangle_out()
> > results in the advertisements being transmitted on the correct
> > interfaces
> Thanks. The problem appears to be that ip6_route_me_harder()
> only uses the socket's oif for the route lookup when the
> socket is bound to an interface, but radvd uses IPV6_PKTINFO
> to specify the outgoing interface.
>=20
> I guess netfilter shouldn't be overriding IPV6_PKTINFO, but
> we unfortunately have neither an indication of this nor the
> original route lookup keys available at the time the packet
> is rerouted.

Mh, I'm not sure, but I guess an indication of netfilter not overriding
IPV6_PKTINFO could be the fact that the source address does not
change...

=46rom my 1st mail:
| # ip6tables -t mangle -A OUTPUT -o eth0 -j MARK --set-mark 1
| # /etc/init.d/radvd start
| -> eth0: <no traffic>
| -> eth1: fe80::2a0:c9ff:fee6:90ce > ff02::1: prefix 2001:6f8:90c:10::/64
| -> eth1: fe80::2d0:b7ff:fe06:6b36 > ff02::1: prefix 2001:6f8:90c:12::/64

fe80::2d0:b7ff:fe06:6b36 is the link-local address of eth0 set by radvd
in IPV6_PKTINFO as well. This, of course, is no guarantee for
ipi6_ifindex not being changed, but I believe if something would have
changed it, it would also have changed ipi6_addr.


Mario
--=20
Doing it right is no excuse for not meeting the schedule.
                                -- Plant Manager, Delphi Corporation

--7ZAtKRhVyVSsbBD2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEVAwUBTT2wlRS+e2HeSPbpAQKnAQf7BF6cP8EOCTP6nIII2iHZLeOg4FELkgak
LeF3iH6OzoTQAUyTOP53sw3PZTmKayRdkd7i2qSRYzQ4WhouFwNDx0KP10HLCwMq
ha9ut70TLwnxXbtoIyHMRBgHO1DvzJgSVvPshzaCREjbgwR9OLUj3J5CuWHxf16X
9Nep9+1PZGLF/iUouzxsIab/2mW+g9wKl2bjaZ27aiqihNm+M3H5bXzfX6LmSCqS
/KpbuAPcKh4PKas4nsDXNdTlcZfvIgHBZBUWawsk2Vr9pQ0HZEexcz4OJGmxn6v9
NUDAJEKmVv24DxMsEapAwYQnx73LbGfiO9Zh109FBmd9TT2h3dGiwA==
=ImCo
-----END PGP SIGNATURE-----

--7ZAtKRhVyVSsbBD2--
