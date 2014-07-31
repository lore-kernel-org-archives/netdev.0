From: Sergey Popov <pinkbyte@gentoo.org>
Subject: Re: Issue with GRE tunnel, created with "local any" on kernel 3.14
Date: Thu, 31 Jul 2014 10:29:00 +0400
Message-ID: <53D9E22C.6030804@gentoo.org>
References: <53C91AA3.1020106@gentoo.org> <20140718223204.9422aa8df81f7ac5187588bb@qrator.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Fr0mi1l4sHFnaUGSIeMW1NxBPvrQoeXJ8"
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:45830 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbaGaG3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 02:29:12 -0400
In-Reply-To: <20140718223204.9422aa8df81f7ac5187588bb@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Fr0mi1l4sHFnaUGSIeMW1NxBPvrQoeXJ8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

18.07.2014 22:32, Dmitry Popov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, 18 Jul 2014 17:01:23 +0400
> Sergey Popov <pinkbyte@gentoo.org> wrote:
>=20
>> Hi. I have updated kernel on one of my servers to 3.14 and hit strange=

>> issue:
>=20
>> serv1(172.30.0.100) <-> serv2(172.30.0.251)
>=20
>> Gre tunnel(serv1):
>> ip tunnel add tun_test mode gre remote 172.30.0.251 local any ttl 225
>> ifconfig tun_test 192.168.0.1/30
>>
>> Gre tunnel(serv2):
>> ip tunnel add tun_test mode gre remote 172.30.0.100 local any ttl 225
>> ifconfig tun_test 192.168.0.2/30
>=20
>> 16:49:39.340971 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
>> 192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 7, length 6=
4
>=20
> Hi!
>=20
> It seems we have this issue since 7d442fab0 (ipv4: Cache dst in tunnels=
).
> It is in ip_tunnel_xmit: fl4 is initialized with saddr =3D 0 in
> init_tunnel_flow(&fl4, protocol, dst, ...), net/ipv4/ip_tunnel.c:610,
> and isn't changed until iptunnel_xmit(skb->sk, ...), line 677, because =

> connected =3D true and rt is almost always cached.
>=20
> I have no patch to fix this issue, but as a workaround, you can use=20
> ip tunnel change tun_test tos inherit.

Thanks, your workaround works as expected if tos value defined
explicitly. Though, I do not understand why: iproute2 documentation says
that default tos value in 'ip tunnel' command is already 'inherit'.

--=20
Best regards, Sergey Popov
Gentoo developer
Gentoo Desktop Effects project lead
Gentoo Qt project lead
Gentoo Proxy maintainers project lead


--Fr0mi1l4sHFnaUGSIeMW1NxBPvrQoeXJ8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT2eIsAAoJECo/aRed9267xbUH/jktg6ZJ6rAi1jJS1zdvUJFn
X8I79OVSWrXlgbzSURdQ7qFRFXaU1a8BQdKYJ1uwSuUosaRA1SaVJZ9lpGpinyeK
NCJIpzfo4cINxIsKiBEe+4PG1JLJLCMYyt7VYvZJcJOygo2JtG+i0kha+rQsB7KX
6NuvoI7kJff52q1n4wtKGn6lffeyW5582J+f6THNPaejtjZ+pvTGpnZ18Mh0Wkqz
KtXxiLuzPpYAv9Nt8M7JY8641cY11WFpA6W4mx67nim8NqzAQYMRwCHQGiApe+bS
Gb9U4Y6pVToofnqfawpazh5IRqzXd5LD153NOqnMrvgN24xrXbh+uZNNjD8nDxY=
=kZdB
-----END PGP SIGNATURE-----

--Fr0mi1l4sHFnaUGSIeMW1NxBPvrQoeXJ8--
