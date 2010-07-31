From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 10/29] LMC: Remove empty media functions.
Date: Sat, 31 Jul 2010 17:05:33 +0200
Message-ID: <1280588752-9340-10-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57508 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507Ab0GaPGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:14 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |    3 ++-
 drivers/net/wan/lmc/media.c |   16 ----------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 6b7c09a..1fbd802 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -692,7 +692,8 @@ static void lmc_watchdog(unsigned long data)
 	}
=20
 	/* Call media specific watchdog functions */
-	sc->lmc_media->watchdog(sc);
+	if (sc->lmc_media->watchdog)
+		sc->lmc_media->watchdog(sc);
=20
 	/* Poke the transmitter to make sure it never stops, even if we run
 	   out of mem */
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 9701d30..2411214 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -428,11 +428,6 @@ static void lmc_hssi_set_crc_length(struct card * =
const sc, int state)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_hssi_watchdog(struct card * const sc)
-{
-	/* HSSI is blank */
-}
-
 static void lmc_hssi_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
@@ -630,10 +625,6 @@ static void lmc_ds3_set_crc_length(struct card * c=
onst sc, int state)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_ds3_watchdog(struct card * const sc)
-{
-}
-
 static void lmc_ds3_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
@@ -907,10 +898,6 @@ static void lmc_t1_set_clock(struct card * const s=
c, int ie)
 	}
 }
=20
-static void lmc_t1_watchdog(struct card * const sc)
-{
-}
-
 static void lmc_t1_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
@@ -941,7 +928,6 @@ struct media lmc_hssi_media =3D {
 	.get_link_status =3D lmc_hssi_get_link_status,
 	.set_link_status =3D lmc_hssi_set_link_status,
 	.set_crc_length =3D lmc_hssi_set_crc_length,
-	.watchdog =3D lmc_hssi_watchdog,
 };
=20
 struct media lmc_ds3_media =3D {
@@ -952,7 +938,6 @@ struct media lmc_ds3_media =3D {
 	.set_scrambler =3D lmc_ds3_set_scram,
 	.get_link_status =3D lmc_ds3_get_link_status,
 	.set_crc_length =3D lmc_ds3_set_crc_length,
-	.watchdog =3D lmc_ds3_watchdog,
 };
=20
 struct media lmc_t1_media =3D {
@@ -963,5 +948,4 @@ struct media lmc_t1_media =3D {
 	.get_link_status =3D lmc_t1_get_link_status,
 	.set_crc_length =3D lmc_t1_set_crc_length,
 	.set_circuit_type =3D lmc_t1_set_circuit_type,
-	.watchdog =3D lmc_t1_watchdog,
 };
--=20
1.7.1.1

