From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 23/29] LMC: lmc_set_protocol() is effectively a NOP, remove it.
Date: Sat, 31 Jul 2010 17:05:46 +0200
Message-ID: <1280588752-9340-23-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39313 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756604Ab0GaPG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:27 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |    2 +-
 drivers/net/wan/lmc/media.c |   27 +++------------------------
 drivers/net/wan/lmc/var.h   |    2 +-
 3 files changed, 5 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 1231d7c..133cc77 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -962,7 +962,7 @@ static void lmc_running_reset(struct net_device *de=
v)
=20
=20
 /* This is what is called when you ifconfig down a device. This disabl=
es
-   the timer for the watchdog and keepalives, and disables the irq for=
 dev. */
+   the watchdog timer and the irq for dev. */
 static int lmc_close(struct net_device *dev)
 {
 	/* not calling release_region() as we should */
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index ecf0f2a..ea5c2bc 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -35,13 +35,6 @@
  * the GNU General Public License version 2, incorporated herein by re=
ference.
  */
=20
-static void lmc_set_protocol(struct card * const sc, struct control *c=
tl)
-{
-	if (!ctl)
-		sc->ictl.keepalive_onoff =3D LMC_CTL_ON;
-}
-
-
 /* SSI methods */
=20
 /* These are bits to program the ssi frequency generator */
@@ -180,7 +173,6 @@ static void lmc_ssi_set_status(struct card * const =
sc, struct control *ctl)
 	if (ctl =3D=3D NULL) {
 		lmc_ssi_set_clock(sc, sc->ictl.clock_source);
 		lmc_ssi_set_speed(sc, &sc->ictl);
-		lmc_set_protocol(sc, NULL);
 		return;
 	}
=20
@@ -197,8 +189,6 @@ static void lmc_ssi_set_status(struct card * const =
sc, struct control *ctl)
=20
 	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
 		lmc_ssi_set_speed(sc, ctl);
-
-	lmc_set_protocol(sc, ctl);
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
@@ -375,21 +365,15 @@ static void lmc_hssi_set_status(struct card * con=
st sc, struct control *ctl)
 {
 	if (ctl =3D=3D NULL) {
 		lmc_hssi_set_clock(sc, sc->ictl.clock_source);
-		lmc_set_protocol(sc, NULL);
-
 		return;
 	}
=20
 	/* check for change in clock source */
-	if (ctl->clock_source && !sc->ictl.clock_source) {
-		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
+	if (ctl->clock_source && !sc->ictl.clock_source)
 		sc->timing =3D LMC_CTL_CLOCK_SOURCE_INT;
-	} else if (!ctl->clock_source && sc->ictl.clock_source) {
+	else if (!ctl->clock_source && sc->ictl.clock_source)
 		sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-	}
-
-	lmc_set_protocol(sc, ctl);
+	lmc_hssi_set_clock(sc, sc->timing);
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
@@ -470,7 +454,6 @@ static void lmc_ds3_set_status(struct card * const =
sc, struct control *ctl)
 	if (ctl =3D=3D NULL) {
 		lmc_ds3_set_100ft(sc, sc->ictl.cable_length);
 		lmc_ds3_set_scram(sc, sc->ictl.scrambler_onoff);
-		lmc_set_protocol(sc, NULL);
 		return;
 	}
=20
@@ -485,8 +468,6 @@ static void lmc_ds3_set_status(struct card * const =
sc, struct control *ctl)
 		lmc_ds3_set_scram(sc, LMC_CTL_ON);
 	else if (!ctl->scrambler_onoff && sc->ictl.scrambler_onoff)
 		lmc_ds3_set_scram(sc, LMC_CTL_OFF);
-
-	lmc_set_protocol(sc, ctl);
 }
=20
 static void lmc_ds3_init(struct card * const sc)
@@ -732,7 +713,6 @@ static void lmc_t1_set_status(struct card * const s=
c, struct control *ctl)
 {
 	if (ctl =3D=3D NULL) {
 		lmc_t1_set_circuit_type(sc, sc->ictl.circuit_type);
-		lmc_set_protocol(sc, NULL);
 		return;
 	}
 	/* check for change in circuit type */
@@ -742,7 +722,6 @@ static void lmc_t1_set_status(struct card * const s=
c, struct control *ctl)
 	else if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1
 		 && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1)
 		lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
-	lmc_set_protocol(sc, ctl);
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 971f5d6..93c21fe 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -152,7 +152,7 @@ struct control {
 	u32 cable_length;		/* DS3 */
 	u32 scrambler_onoff;		/* DS3 */
 	u32 cable_type;			/* T1 */
-	u32 keepalive_onoff;		/* protocol */
+	u32 keepalive_onoff;		/* unused */
 	u32 ticks;			/* ticks/sec */
 	union {
 		lmc_av9110_t ssi;
--=20
1.7.1.1

