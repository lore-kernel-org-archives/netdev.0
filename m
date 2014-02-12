From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 07/14] ethtool: Update documentation of struct
 ethtool_pauseparam
Date: Wed, 12 Feb 2014 22:14:28 +0000
Message-ID: <1392243268.15615.11.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tztr69A1LWkrRasz8o6t"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52791 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475AbaBLWOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:35 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tztr69A1LWkrRasz8o6t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Convert the inline comments to kernel-doc format.

Explicitly specify that non-zero autoneg is an error if link
autonegotiation is disabled.

Specify that pause capabilities should be advertised dependent on link
autonegotiation, not the autoneg flag here.  There is no way to
opt-out of pause frame autonegotiation, and this improves behaviour
when the link partner is configured to follow pause frame
autonegotiation and our interface is not.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e602cd0..8ca2924 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -466,20 +466,30 @@ struct ethtool_channels {
 	__u32	combined_count;
 };
=20
-/* for configuring link flow control parameters */
+/**
+ * struct ethtool_pauseparam - Ethernet pause (flow control) parameters
+ * @cmd: Command number =3D %ETHTOOL_GPAUSEPARAM or %ETHTOOL_SPAUSEPARAM
+ * @autoneg: Flag to enable autonegotiation of pause frame use
+ * @rx_pause: Flag to enable reception of pause frames
+ * @tx_pause: Flag to enable transmission of pause frames
+ *
+ * Drivers should reject a non-zero setting of @autoneg when
+ * autoneogotiation is disabled (or not supported) for the link.
+ *
+ * If the link is autonegotiated, drivers should use
+ * mii_advertise_flowctrl() or similar code to set the advertised
+ * pause frame capabilities based on the @rx_pause and @tx_pause flags,
+ * even if @autoneg is zero.  They should also allow the advertised
+ * pause frame capabilities to be controlled directly through the
+ * advertising field of &struct ethtool_cmd.
+ *
+ * If @autoneg is non-zero, the MAC is configured to send and/or
+ * receive pause frames according to the result of autonegotiation.
+ * Otherwise, it is configured directly based on the @rx_pause and
+ * @tx_pause flags.
+ */
 struct ethtool_pauseparam {
-	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
-
-	/* If the link is being auto-negotiated (via ethtool_cmd.autoneg
-	 * being true) the user may set 'autoneg' here non-zero to have the
-	 * pause parameters be auto-negotiated too.  In such a case, the
-	 * {rx,tx}_pause values below determine what capabilities are
-	 * advertised.
-	 *
-	 * If 'autoneg' is zero or the link is not being auto-negotiated,
-	 * then {rx,tx}_pause force the driver to use/not-use pause
-	 * flow control.
-	 */
+	__u32	cmd;
 	__u32	autoneg;
 	__u32	rx_pause;
 	__u32	tx_pause;


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-tztr69A1LWkrRasz8o6t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyROe/yOyVhhEJAQqZ+w/+PWiYTqMhn8pPwkTmIETNOy73L/jT/2d3
+VLkREDn9NG++lsCXYR2RUpZQCXeSyjAMyPviAQAX/8RHgxYBuxfeXUk0aN0lrze
+sczIyBpWwaNTEZG+XU21JgGFbAGNuI1UC/FzymPEPN/8IdGGJOMKzAMl8nSnMzy
vPA/aR7Ao0utF5ULlG/3wpPDgttT12R/xjLNjSrO0l6kL6BzKdwrwjW7ERDjmKhe
gqVRElBZA3Q0IoYnoKpFPqtx/FM9J91NwWS7YFhq3envFHvMzeo6ZFg2vCTP+ttO
2us8qp5Wru59c7dMUCjjm/r12muSB7hcbd+NwlkmKLGOpXVf1TWoa/f8BZO2Mg9H
XTtgHblt3PwxGAilMS8ZwcX0DsP9m+uE1UqKMhe7xPVyYG+UnVfbECsE5gkJgKoR
ZOfj8cc8DDZ5ITiFDe+WlSKL0ElrinzrKUYBU5WZ5j8MznoU5lGZugwb92/uOQiN
0k+teRlAp0TeicyAzD53wZTl2ULl8bFYXjMgQ9N7b+qvLGVIcyuxc8tSPM/5ar6L
nuQuIEdNJezWsG+VbEGt9bT05XooWTkwMHlUncO1S83zx0IiTFUbukDRunMVwqdz
NewIql7xMOIM5DukWcZTOGg+UljlDaF2vRjNLizLsTDkqYKkgI9lh7Mk/tgODYGL
ObQf+iyP2bw=
=79GU
-----END PGP SIGNATURE-----

--=-tztr69A1LWkrRasz8o6t--
