From: "D. S. Ljungmark" <spider@takeit.se>
Subject: [PATCH] ipv6: Don't reduce hop limit for an interface
Date: Wed, 25 Mar 2015 09:29:01 +0100
Message-ID: <1427272141.10689.7.camel@takeit.se>
Reply-To: ljungmark@modio.se
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-rvfNKfZQ961lCzDfCWyH"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36162 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbbCYI3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 04:29:06 -0400
Received: by lbbug6 with SMTP id ug6so12018207lbb.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 01:29:05 -0700 (PDT)
Received: from waves.skuggor.se ([2001:470:ddd2:1::4f9])
        by mx.google.com with ESMTPSA id ef8sm421035lbd.0.2015.03.25.01.29.03
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 01:29:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rvfNKfZQ961lCzDfCWyH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

=46rom 3ae93eb68a06ab2d9c984c6708dbc9e5f3bc8251 Mon Sep 17 00:00:00 2001
From: "D.S. Ljungmark" <ljungmark@modio.se>
Date: Wed, 25 Mar 2015 09:28:15 +0100
Subject: [PATCH] ipv6: Don't reduce hop limit for an interface

A local route may have a lower hop_limit set than global routes do.

RFC 3756, Section 4.2.7, "Parameter Spoofing"

>   1.  The attacker includes a Current Hop Limit of one or another small
>       number which the attacker knows will cause legitimate packets to
>       be dropped before they reach their destination.

>   As an example, one possible approach to mitigate this threat is to
>   ignore very small hop limits.  The nodes could implement a
>   configurable minimum hop limit, and ignore attempts to set it below
>   said limit.

Signed-off-by: D.S. Ljungmark <ljungmark@modio.se>
---
 net/ipv6/ndisc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 471ed24..14ecdaf 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1218,7 +1218,14 @@ static void ndisc_router_discovery(struct sk_buff *s=
kb)
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
 	if (ra_msg->icmph.icmp6_hop_limit) {
-		in6_dev->cnf.hop_limit =3D ra_msg->icmph.icmp6_hop_limit;
+		/* Only set hop_limit on the interface if it is higher than
+		 * the current hop_limit.
+		 */
+		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
+			in6_dev->cnf.hop_limit =3D ra_msg->icmph.icmp6_hop_limit;
+		} else {
+			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit th=
an current\n");
+		}
 		if (rt)
 			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
 				       ra_msg->icmph.icmp6_hop_limit);
--=20
2.1.0



--=-rvfNKfZQ961lCzDfCWyH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVEnHNAAoJEPzDdnREnjz8OscP/131gppGLTMDom6ghP7ORPFN
fpfnvYPrFpaXHsgQOrVdnORTt8FBRxhIl6Acd7caifTo3gytpFMg2CLCwp7luk/S
Bif4BaVctI+MNHddLKCCRtPX66De/RyRW1bqdlmm5dJgp/TtyVSrVdvadz9Ogn4L
0OrK9Jj++vS86aeXE6CzhmC722d27j/x9/Yp1tIM0bXrLmgbZGNxJCq5NEDveWjy
E9ziL08aChsrESYRX3sbAZmczQdD/c5AwOlqe+dGZMaQYcTfQebNVrU9lodQsbOG
L/Z2wG3fZxbjnACrra7QFOxWeITewTq6/hNPnAdrORfGf0HGuXJZ2qzz5RhCICoD
FGFtaGzySoEQ94LkSaPTajb1H+DGdmpQyMPrIcnzAYd7imAfDf+kx31Fg3DxpkWW
wcwThIlR+jn/tk5AOjjFFpenY02DNC8Fi91bqg/OTlMlF2PUus/RRQa9INe8Zqht
zvbowNk9fm7fRXMRz8Xcnwl7+c1YTIUdHKK3ndLD5qZ19K6oCwedEOI0LG7KrM94
y1Lw/rG/tHnyx0tWnZIJNSwNC+cusPSqVSnToInPvh1dVYOxfiFq5D2Y389Mrq5I
wPWugMQ7rN+zpGijdkiP4vi1usRmfufh9dWt7mA3Oypp43b+SOJeTg+aJ3fqgX9d
BiHLXoIYnjd9cqTirkOD
=ap0A
-----END PGP SIGNATURE-----

--=-rvfNKfZQ961lCzDfCWyH--
