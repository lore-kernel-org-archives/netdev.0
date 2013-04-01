From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [Suggestion] drivers/isdn/divert: break looping, or memory leak
 by calling kmalloc again
Date: Mon, 01 Apr 2013 12:08:26 +0200
Message-ID: <51595C9A.1060608@imap.cc>
References: <5158ECBD.4050109@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7D74E0B365E3D9F898F2E043"
Cc: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44834 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756763Ab3DAKIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 06:08:30 -0400
In-Reply-To: <5158ECBD.4050109@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7D74E0B365E3D9F898F2E043
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.04.2013 04:11, schrieb Chen Gang:
> in drivers/isdn/divert/isdn_divert.c:
>=20
>   in 'for' looping (line 395..515)
>     the 'cs' may call kmalloc again (line 453).
>=20
>   it seems need break looping, when get valid 'cs' value (line 509)

I don't think so. If the kmalloc for cs succeeds, control flow will
continue linearly up to the 'if' statement in line 503. Then it will
either kfree(cs) and return, or reach the 'break' in line 514 which
will end the 'for' loop.

HTH
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig7D74E0B365E3D9F898F2E043
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlFZXJsACgkQQ3+did9BuFsWsgCfemIpCdw9Z25IMYq8rH1FuZjf
9skAnjseLVEkmGr3CzPkTI/+oiCM8MLH
=iSh7
-----END PGP SIGNATURE-----

--------------enig7D74E0B365E3D9F898F2E043--
