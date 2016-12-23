From: Mart van Santen <mart@greenhost.nl>
Subject: [PATCH] vif queue counters from int to long
Date: Fri, 23 Dec 2016 16:09:23 +0100
Message-ID: <585D3E23.10509@greenhost.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="QgpnRBtCQaNUX6oBRkEr2LdEge2jumDom"
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost1.greenhost.nl ([195.190.28.81]:50262 "EHLO
        smarthost1.greenhost.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759000AbcLWP1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 10:27:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QgpnRBtCQaNUX6oBRkEr2LdEge2jumDom
Content-Type: multipart/mixed; boundary="Q0tcOJvR06RN8ibwU2iVclMGMFpOV3BNO";
 protected-headers="v1"
From: Mart van Santen <mart@greenhost.nl>
To: netdev@vger.kernel.org
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com
Message-ID: <585D3E23.10509@greenhost.nl>
Subject: [PATCH] vif queue counters from int to long

--Q0tcOJvR06RN8ibwU2iVclMGMFpOV3BNO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Hello,

This patch fixes an issue where counters in the queue have type int,
while the counters of the vif itself are specified as long. This can
cause incorrect reporting of tx/rx values of the vif interface.
More extensively reported on xen-devel mailinglist.



Signed-off-by: Mart van Santen <mart@greenhost.nl>
--- a/drivers/net/xen-netback/common.h  2016-12-22 15:41:07.785535748 +00=
00
+++ b/drivers/net/xen-netback/common.h  2016-12-23 13:08:18.123080064 +00=
00
@@ -113,10 +113,10 @@ struct xenvif_stats {
         * A subset of struct net_device_stats that contains only the
         * fields that are updated in netback.c for each queue.
         */
-       unsigned int rx_bytes;
-       unsigned int rx_packets;
-       unsigned int tx_bytes;
-       unsigned int tx_packets;
+       unsigned long rx_bytes;
+       unsigned long rx_packets;
+       unsigned long tx_bytes;
+       unsigned long tx_packets;

        /* Additional stats used by xenvif */
        unsigned long rx_gso_checksum_fixup;

--=20
Mart van Santen
Greenhost
E: mart@greenhost.nl
T: +31 20 4890444
W: https://greenhost.nl

A PGP signature can be attached to this e-mail,
you need PGP software to verify it.=20
My public key is available in keyserver(s)
see: http://tinyurl.com/openpgp-manual

PGP Fingerprint: CA85 EB11 2B70 042D AF66  B29A 6437 01A1 10A3 D3A5



--Q0tcOJvR06RN8ibwU2iVclMGMFpOV3BNO--

--QgpnRBtCQaNUX6oBRkEr2LdEge2jumDom
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYXT4jAAoJEGQ3AaEQo9OlkysH/jhIiw95d/DzaeJTJZ6Ef/jt
0rTnBNd+8RUWYYU9ZN7T8QfQ/aoX4MfnUpiYxQcPRGpIXjdOJX4EUqq4mWOrEssV
tufRU/w4RrHdsL+mo8Qi0NQDeoqpp6Ld+vYDiLFcrl7yDBig6ZPvE7ut44ywLVfa
3ha8QeVniyC10a8LIp8NqJxJse3eyDVVEMMCx640H34Qef5LP/6O6ohM3minZkgZ
NKWntLmUXQslppjYfFaUa3RRZGLlBo28eE5LosdxAZy3/KLmM0WF1/hODd69n5Sy
+X7XSuPh0KQnpNLBNtNfxlD5h1ExIvpoDGarVNCkbzCUXEHKdvM3ha/gC/OpOhg=
=lIDH
-----END PGP SIGNATURE-----

--QgpnRBtCQaNUX6oBRkEr2LdEge2jumDom--
