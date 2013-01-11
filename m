From: Roman Mamedov <rm@romanrm.ru>
Subject: Re: Problem with IPv6 Route Cache
Date: Fri, 11 Jan 2013 22:37:55 +0600
Message-ID: <20130111223755.714ddf7f@natsu>
References: <20130111185126.56cababe@natsu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/KNkZuFUwOtFX8rx6qqOLjv_"; protocol="application/pgp-signature"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from len.romanrm.net ([176.31.121.172]:51817 "EHLO len.romanrm.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754711Ab3AKQiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 11:38:02 -0500
Received: from natsu (unknown [IPv6:fd39::1e6f:65ff:fea1:3ea6])
	by len.romanrm.net (Postfix) with ESMTPS id 2745A205D5
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 16:38:00 +0000 (UTC)
In-Reply-To: <20130111185126.56cababe@natsu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/KNkZuFUwOtFX8rx6qqOLjv_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hello,

I have discovered that when the problem is occuring, I have:

root@neru:~# ip -6 neigh
fd39:20::39 dev tun-rm  FAILED
fe80::20b:45ff:fe80:c000 dev eth0 lladdr 00:0b:45:80:c0:00 router REACHABLE
2a02:e00:ffff:56::1 dev eth0 lladdr 00:0b:45:80:c0:00 router REACHABLE

Launching "ping6 fd39:20::39" turns fd39:20::39 from FAILED to REACHABLE.
After that, "ip -6 route flush cache" actually succeeds in removing the rou=
te
via default gateway, and I then get the proper route entry:

root@neru:~# ip -6 route get fd39::100
fd39::100 from :: via fd39:20::39 dev tun-rm  src fd39:20::3  metric 0=20
    cache

So I conclude that my issue is very similar to [1] mentioned in a Bugzilla
entry [2] linked here just today.

  [1] https://lkml.org/lkml/2012/5/25/96
  [2] https://bugzilla.kernel.org/show_bug.cgi?id=3D42991

--=20
With respect,
Roman

~~~~~~~~~~~~~~~~~~~~~~~~~~~
"Stallman had a printer,
with code he could not see.
So he began to tinker,
and set the software free."

--Sig_/KNkZuFUwOtFX8rx6qqOLjv_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlDwP+MACgkQTLKSvz+PZwjBngCdEWG1ikJOug/eorUVjLYNRGfc
nS8AniNZTSvXC67IexxkX8gka8YHq6p7
=zlkK
-----END PGP SIGNATURE-----

--Sig_/KNkZuFUwOtFX8rx6qqOLjv_--
