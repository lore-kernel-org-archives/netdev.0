From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next] cgxb4: Stop using ethtool SPEED_* constants
Date: Sun, 23 Feb 2014 00:03:24 +0000
Message-ID: <1393113804.6823.21.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8MQbymJ2krooyuX4zSRm"
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Kumar Sanghvi <kumaras@chelsio.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58386 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbaBWAD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 19:03:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8MQbymJ2krooyuX4zSRm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ethtool speed values are just numbers of megabits and there is no need
to add SPEED_40000.  To be consistent, use integer constants directly
for all speeds.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 20 ++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  8 ++++----
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index 4660f55..da4edc1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -427,16 +427,16 @@ static void link_report(struct net_device *dev)
 		const struct port_info *p =3D netdev_priv(dev);
=20
 		switch (p->link_cfg.speed) {
-		case SPEED_10000:
+		case 10000:
 			s =3D "10Gbps";
 			break;
-		case SPEED_1000:
+		case 1000:
 			s =3D "1000Mbps";
 			break;
-		case SPEED_100:
+		case 100:
 			s =3D "100Mbps";
 			break;
-		case 40000: /* Need a SPEED_40000 in ethtool.h */
+		case 40000:
 			s =3D "40Gbps";
 			break;
 		}
@@ -2274,13 +2274,13 @@ static int get_settings(struct net_device *dev, str=
uct ethtool_cmd *cmd)
=20
 static unsigned int speed_to_caps(int speed)
 {
-	if (speed =3D=3D SPEED_100)
+	if (speed =3D=3D 100)
 		return FW_PORT_CAP_SPEED_100M;
-	if (speed =3D=3D SPEED_1000)
+	if (speed =3D=3D 1000)
 		return FW_PORT_CAP_SPEED_1G;
-	if (speed =3D=3D SPEED_10000)
+	if (speed =3D=3D 10000)
 		return FW_PORT_CAP_SPEED_10G;
-	if (speed =3D=3D 40000) /* Need SPEED_40000 in ethtool.h */
+	if (speed =3D=3D 40000)
 		return FW_PORT_CAP_SPEED_40G;
 	return 0;
 }
@@ -2310,8 +2310,8 @@ static int set_settings(struct net_device *dev, struc=
t ethtool_cmd *cmd)
 		cap =3D speed_to_caps(speed);
=20
 		if (!(lc->supported & cap) ||
-		    (speed =3D=3D SPEED_1000) ||
-		    (speed =3D=3D SPEED_10000) ||
+		    (speed =3D=3D 1000) ||
+		    (speed =3D=3D 10000) ||
 		    (speed =3D=3D 40000))
 			return -EINVAL;
 		lc->requested_speed =3D cap;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ether=
net/chelsio/cxgb4/t4_hw.c
index 7ae756d..d3c2a51 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3567,13 +3567,13 @@ int t4_handle_fw_rpl(struct adapter *adap, const __=
be64 *rpl)
 		if (stat & FW_PORT_CMD_TXPAUSE)
 			fc |=3D PAUSE_TX;
 		if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
-			speed =3D SPEED_100;
+			speed =3D 100;
 		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
-			speed =3D SPEED_1000;
+			speed =3D 1000;
 		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
-			speed =3D SPEED_10000;
+			speed =3D 10000;
 		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_40G))
-			speed =3D 40000; /* Need SPEED_40000 in ethtool.h */
+			speed =3D 40000;
=20
 		if (link_ok !=3D lc->link_ok || speed !=3D lc->speed ||
 		    fc !=3D lc->fc) {                    /* something changed */

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-8MQbymJ2krooyuX4zSRm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwk6zOe/yOyVhhEJAQoiPxAAzRp02/ecG+l7bZS8XRuc1qg2cDwgv5HW
hpq15JctpvNwPRl4jT4WaIAoFrzsfh7WhyGvr71IVcqDdIdsZU1wqZLS2dzCaLqK
6YptPNwOk2qDukBEjFAIIfRILH9LWJrksrHE0dOgidzLcPwmiFEmtAIOWTOxI0yv
Rs0VV4h7Q1N5/sFHRCWQkUplF0rylZCdClIc6PgsKJY5uOA9iq3rDa+AL9XfLIRF
7dRv/1fArx27EO0hT4n8O0UJnVUKpGyEC4T85v7/0lqojP313IdNdqHpEhgRrPKw
Jn0PVjsIJwTho8b/8H3iwyhUK415hQKEjZ7DsFTSXlHKEG/LTgD8yJk3mijxTbMM
v0JjnnTRtnNT4wtvoz2Gu5jLzN7E/XFlnA+45F7kwIO5fO9crWiv2j22k76BkPKm
nEgQlQbnhy3Oacv36gKXG6d0rBKBIKB/tVW3NC9dtXsl6YN7QLHGvbeef4tnU1wB
fUOxvSaVxyUhk4Netkfz/bxUcPiGcWLUgwZACEbDBH9isArSjs167ziWCqgexhMd
cppNnfoC0JH/bievg4Ubs0SPZHR0AOBBKfL4cmW8qtjCHdjjtM6gZnQ7xCCjq8XB
u4JHE3GxA5lc6peW8HMOQK+t4BIidLdLxejuF5HZRPgwyEqRi1NiLXLPEovUiq7I
alLdb5An8/A=
=FJ28
-----END PGP SIGNATURE-----

--=-8MQbymJ2krooyuX4zSRm--
