From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 5/6] llc2: Remove explicit indexing of state action
 arrays
Date: Sun, 16 Sep 2012 04:11:40 +0100
Message-ID: <1347765100.13258.213.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/gAEOe6GKUQ6mG+JGgw8"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53028 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750740Ab2IPDLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:11:44 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/gAEOe6GKUQ6mG+JGgw8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

These arrays are accessed by iteration in
llc_exec_station_trans_actions().  There must not be any zero-filled
gaps in them, so the explicit indices are pointless.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 48c2118..fe43158 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -111,8 +111,8 @@ free:
=20
 /* state transition for LLC_STATION_EV_RX_NULL_DSAP_XID_C event */
 static llc_station_action_t llc_stat_up_state_actions_2[] =3D {
-	[0] =3D llc_station_ac_send_xid_r,
-	[1] =3D NULL,
+	llc_station_ac_send_xid_r,
+	NULL,
 };
=20
 static struct llc_station_state_trans llc_stat_up_state_trans_2 =3D {
@@ -122,8 +122,8 @@ static struct llc_station_state_trans llc_stat_up_state=
_trans_2 =3D {
=20
 /* state transition for LLC_STATION_EV_RX_NULL_DSAP_TEST_C event */
 static llc_station_action_t llc_stat_up_state_actions_3[] =3D {
-	[0] =3D llc_station_ac_send_test_r,
-	[1] =3D NULL,
+	llc_station_ac_send_test_r,
+	NULL,
 };
=20
 static struct llc_station_state_trans llc_stat_up_state_trans_3 =3D {



--=-/gAEOe6GKUQ6mG+JGgw8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDbOe/yOyVhhEJAQpoNg//bNWaVvmDnjnmMhnGnA0vXz3iEzt38/va
qKLlkURCJqB+NSeJltbsslOyXSRyW3w9mjQi2jueSIId66LPoJwIOnM6IAQediKo
FsofVnSaBNWRljPJLrdru7NboKi11ySQ3HkpirxaFzWAiatWS1kP9k65T00gJ97y
VZuHZ2+ssdDp6BW11I2dxqbA+7wuXivGBrfHD8wyv2gHrKTGsxhaRCBRREvRnNyZ
tKqK4LyowteZTrtHynud8dqkbYiDi0DAq19cQCClpHCDZcKsp9HzfVHE9MMEgc27
0KHQk/L2797fZYj8Q8LtVaOGEddjNVvo/EFhPQySViA63UGgqtLf1Q8msEQ3G6+E
zbiUZyPXZNVBbTH57BMHYbFx8li/Pu/pkyfoyOJbNJ5/COJfURO2+Zbn2ItwaWBt
CRc84jFhKmaoglIIG2QdbA/ggoKXiRajmOFlzEqjjj4zbS+B8LoTAvHBRMIunBM8
lxFa8O/AwscRpeJbGmRITbqzm6FQiwplVzOy0sVJttgXnBaBOAZmoWMjeiFq+oD7
haa0tN+q6svDJt6dKDsXFVwYXv9nPDPV48fek0zN3gRDE/e1u522g99dx1At3Z5j
Zz9F4RWCqxtqyoKELicdIQOFl7OUPYBuzt51u2teOWiKMCg4bkGZ9HnPWvG3H7jD
fd8jYFRftWg=
=R19v
-----END PGP SIGNATURE-----

--=-/gAEOe6GKUQ6mG+JGgw8--
