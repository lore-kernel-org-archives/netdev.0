From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/6] llc2: Remove pointless indirection through
 llc_stat_state_trans_end
Date: Sun, 16 Sep 2012 04:10:52 +0100
Message-ID: <1347765052.13258.209.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EtzixrnaJ6qBlu5rP5fs"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53009 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142Ab2IPDK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:10:57 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EtzixrnaJ6qBlu5rP5fs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index b2f2bac..e16c1b9 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -331,14 +331,6 @@ static int llc_station_ac_report_status(struct sk_buff=
 *skb)
 	return 0;
 }
=20
-/* COMMON STATION STATE transitions */
-
-/* dummy last-transition indicator; common to all state transition groups
- * last entry for this state
- * all members are zeros, .bss zeroes it
- */
-static struct llc_station_state_trans llc_stat_state_trans_end;
-
 /* DOWN STATE transitions */
=20
 /* state transition for LLC_STATION_EV_ENABLE_WITH_DUP_ADDR_CHECK event */
@@ -372,7 +364,7 @@ static struct llc_station_state_trans llc_stat_down_sta=
te_trans_2 =3D {
 static struct llc_station_state_trans *llc_stat_dwn_state_trans[] =3D {
 	[0] =3D &llc_stat_down_state_trans_1,
 	[1] =3D &llc_stat_down_state_trans_2,
-	[2] =3D &llc_stat_state_trans_end,
+	[2] =3D NULL,
 };
=20
 /* UP STATE transitions */
@@ -417,7 +409,7 @@ static struct llc_station_state_trans *llc_stat_up_stat=
e_trans [] =3D {
 	[0] =3D &llc_stat_up_state_trans_1,
 	[1] =3D &llc_stat_up_state_trans_2,
 	[2] =3D &llc_stat_up_state_trans_3,
-	[3] =3D &llc_stat_state_trans_end,
+	[3] =3D NULL,
 };
=20
 /* DUP ADDR CHK STATE transitions */
@@ -512,7 +504,7 @@ static struct llc_station_state_trans *llc_stat_dupaddr=
_state_trans[] =3D {
 	[3] =3D &llc_stat_dupaddr_state_trans_1,	/* Receive frame */
 	[4] =3D &llc_stat_dupaddr_state_trans_2,
 	[5] =3D &llc_stat_dupaddr_state_trans_3,
-	[6] =3D &llc_stat_state_trans_end,
+	[6] =3D NULL,
 };
=20
 static struct llc_station_state
@@ -568,7 +560,7 @@ static struct llc_station_state_trans *
 	struct llc_station_state *curr_state =3D
 				&llc_station_state_table[llc_main_station.state - 1];
=20
-	for (next_trans =3D curr_state->transitions; next_trans[i]->ev; i++)
+	for (next_trans =3D curr_state->transitions; next_trans[i]; i++)
 		if (!next_trans[i]->ev(skb)) {
 			rc =3D next_trans[i];
 			break;



--=-EtzixrnaJ6qBlu5rP5fs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDPOe/yOyVhhEJAQq/Fg/+IMlfcn0Pzgla0qMaT5jxvBc6hOu/XcZf
aVopBlN/MZMdEt/jSeB6LaqJiZ1GDENyPl4SAN4n8d+Ch+LDel2q/aS1oim/+EIt
y+GPvVlkC90Z+pThA7AM6XrWCnC5u8HP2q147ZyMrJ0iuzqLH8rs1J7ITihQtaaB
wa8Mz0Nq8i5Fojl39aWYjs3F0S0r1QOVY3DyqnLifsoqe7LH75g5cRfKQB3hvpvn
ihskY898Q/Dz2hbIMngW8DRyOvqZKWitHN5bplqSPw9ZAvuR6sODfy4GM4CUs1Y8
IskbgsrBxVeZ3VnR7yaCWJHrCsPka1EgM2AxZ3eOdk73Tqtp7ptbwBjqI5J0SbPB
RsuYZJodH51v20XJMw3/Z2QAFYHM+66FbdN+cktmW2yYQmyzF30A14d9yrR5gaK+
VBSgiv/t8o6pekNPIgsVwj5O5qCQ35FKJhQzEHxb2alRtdxKweqcjYoGBIGJhhsy
Y3fWTAgIqjueuN7Cg/uNNaejueaEH/5xY2EjeK9StR0lbkvWndQ5CJZlnsQ5UXB/
L04BzF/kHIH4/BKc8oVCBAeUKbrmuElmZbtDZmT4dKaRX0AIOkpQxoxf0IDStCLK
zRMCw1zy7Qeunm131tQ7cka2RVPrvMfVgX4hDrqP9SzwzT9VlfRHF6n0CZa6KmYx
wuvd14OhY3I=
=CTf4
-----END PGP SIGNATURE-----

--=-EtzixrnaJ6qBlu5rP5fs--
