From: Martin von Gagern <Martin.vGagern@gmx.net>
Subject: iproute2: no error messages for unsupported table requests
Date: Sat, 25 Aug 2007 18:29:12 +0200
Message-ID: <46D058D8.3030206@gmx.net>
Reply-To: Martin von Gagern <Martin.vGagern@gmx.net>,
	  netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2DE49BDD02A7148F5125C291"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:33760 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753296AbXHYRa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 13:30:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2DE49BDD02A7148F5125C291
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi!

A while ago I've tried to configure multiple routing tables using
iproute2-2.6.20. As my kernel at that time was configured without
CONFIG_IP_MULTIPLE_TABLES this could not work. However, I got no error
message from the ip command, the route was added to the main table, and
it took me quite a while to locate the error.

=46rom what a quick diff to 2.6.22 tells me, there seems to be no change
addressing the issue, so I guess the same would hold for that version.

Originally I had reported this issue with my distro, Gentoo:
http://bugs.gentoo.org/show_bug.cgi?id=3D181928
Now a Gentoo dev directed me towards this list here.

There I also posted the steps I used to reproduce the issue:
 ip route add 123.45.67.89 dev ppp0 table 100
 ip route show table 100
 ip route show table main
Expected result:
 route listed in table 100 but not listed in table main
Actual result:
 route listed in table main, table 100 still empty

I now have resolved the issue for me by reconfiguring my kernel, but you
could probably save others some trouble by generating an error message
in case the kernel doesn't support multiple tables.

Greetings,
 Martin von Gagern


--------------enig2DE49BDD02A7148F5125C291
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFG0FjkRhp6o4m9dFsRAheJAJ4p0kLqhzR/AFR1kjfCzeWn0bc+oACfWA1X
RSgWO498khTT3A++Cum0xWc=
=r/dt
-----END PGP SIGNATURE-----

--------------enig2DE49BDD02A7148F5125C291--
