From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool] Fix iteration count in sff8472_calibration()
Date: Sun, 22 Sep 2013 02:36:42 +0100
Message-ID: <1379813802.21174.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EQkYUYziERbRVua1rGhc"
Cc: netdev <netdev@vger.kernel.org>,
	Aurelien Guillaume <aurelien@iwi.me>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44472 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752505Ab3IVBhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 21:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EQkYUYziERbRVua1rGhc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We want to iterate over all elements of the various arrays of readings
(which all have the same dimensions - and maybe ought to be a single
array).  Unfortunately the iteration count is sizeof(sd->bias_cur) and
bias_cur has 2-byte elements, so we iterate over twice as many
elements as are really there.

Compiler-detected, and compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 sfpdiag.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/sfpdiag.c b/sfpdiag.c
index f67e491..04fd880 100644
--- a/sfpdiag.c
+++ b/sfpdiag.c
@@ -224,7 +224,7 @@ static void sff8472_calibration(const __u8 *id, struct =
sff8472_diags *sd)
 	__u16 rx_reading;
=20
 	/* Calibration should occur for all values (threshold and current) */
-	for (i =3D 0; i < sizeof(sd->bias_cur); ++i) {
+	for (i =3D 0; i < ARRAY_SIZE(sd->bias_cur); ++i) {
 		/*
 		 * Apply calibration formula 1 (Temp., Voltage, Bias, Tx Power)
 		 */


--=-EQkYUYziERbRVua1rGhc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUj5Jque/yOyVhhEJAQo95w//bv1ili0z/r0g4T0c7p7/2f7Xvgei5vdR
/qcbW2JV8s4i8vhCBRRbhVkmP6bqQNeRe9izWv6+bpJsNYVOL01F58zBq01dXfm8
5dxvp2uSIJB8uITnAm6eOcn+k4DMfJN/GWdsdqY6+ufkdcaEcKNrViT2aKINJdqr
3GxkErhGs0dgUvU5TV+bjmfm/NJeMNCrsxJmtBqfhaH/4je7NEe5rpofEyYr8BYq
zP47XbFu8eNasd/e97xccaaEWENmoGefxrTAISuQIJqFkgg2qiAFDE+EVF8NcvP7
X2HkJCV3K2+ctivmcXCxtdsJ/Kx3vOLW5XGLbZdc28RMbgj491D9rFbXZckHjX3w
BUmpTBA4nlcfPuDpScwm1eAVwQ/1DDXMsO6qMTiyVvl8RcfHXpPvqCTemOvffxhJ
6VqVkVfoOrKJXBUVuIu3TeYPRcC0Uyn9qPtDfgDkXAVccMDdpjUdAfT3RBAoNG7L
nWeyauw161i7NHy7OEwW0S+sbVWz1IW3SQ1xfoYZ6sHL0uuZLtARfWUFWsIIVzew
NhkInKbNLmvJYUAq92f5/VQbC08L+h6goJQwbtuCQjvHHWLdwjxNFZh7f4R8kHYx
h5AIGKJqCKPJngT70Eej2CLBbFcvqqK084Bx7WZ9QYkvv0qgNh/Lqlb67CYqRq1n
DoHwW4pQM7g=
=qPPS
-----END PGP SIGNATURE-----

--=-EQkYUYziERbRVua1rGhc--
