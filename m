From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 27/29] LMC: Remove redundant card->name.
Date: Sat, 31 Jul 2010 17:05:50 +0200
Message-ID: <1280588752-9340-27-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35430 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756609Ab0GaPG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:27 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |    3 +--
 drivers/net/wan/lmc/media.c |   40 ++++++++++++++++++++++-------------=
-----
 drivers/net/wan/lmc/var.h   |    1 -
 3 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 133cc77..13383a5 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -754,7 +754,6 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	dev->watchdog_timeo =3D HZ; /* 1 second */
 	dev->tx_queue_len =3D 100;
 	sc->netdev =3D dev;
-	sc->name =3D dev->name;
 	dev->base_addr =3D pci_resource_start(pdev, 0);
 	dev->irq =3D pdev->irq;
 	pci_set_drvdata(pdev, dev);
@@ -1624,7 +1623,7 @@ static void lmc_softreset(struct card * const sc)
 			if (skb =3D=3D NULL) {
 				printk(KERN_WARNING
 				       "%s: Failed to allocate receiver ring, will try again\n",
-				       sc->name);
+				       sc->netdev->name);
 				sc->failed_ring =3D 1;
 				break;
 			} else
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index ea5c2bc..b9fadb4 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -230,13 +230,14 @@ static int lmc_ssi_get_link_status(struct card * =
const sc)
 		if (sc->last_led_err[3] !=3D 1) {
 			sc->extra_stats.tx_lossOfClockCnt++;
 			printk(KERN_WARNING "%s: Lost Clock, Link Down\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		sc->last_led_err[3] =3D 1;
 		lmc_led_on(sc, LMC_MII16_LED3);	/* turn ON red LED */
 	} else {
 		if (sc->last_led_err[3] =3D=3D 1)
-			printk(KERN_WARNING "%s: Clock Returned\n", sc->name);
+			printk(KERN_WARNING "%s: Clock Returned\n",
+			       sc->netdev->name);
 		sc->last_led_err[3] =3D 0;
 		lmc_led_off(sc, LMC_MII16_LED3); /* turn OFF red LED */
 	}
@@ -255,12 +256,14 @@ static int lmc_ssi_get_link_status(struct card * =
const sc)
=20
 	if (hw_hdsk =3D=3D 0) {
 		if (sc->last_led_err[1] !=3D 1)
-			printk(KERN_WARNING "%s: DSR not asserted\n", sc->name);
+			printk(KERN_WARNING "%s: DSR not asserted\n",
+			       sc->netdev->name);
 		sc->last_led_err[1] =3D 1;
 		lmc_led_off(sc, LMC_MII16_LED1);
 	} else {
 		if (sc->last_led_err[1] !=3D 0)
-			printk(KERN_WARNING "%s: DSR now asserted\n", sc->name);
+			printk(KERN_WARNING "%s: DSR now asserted\n",
+			       sc->netdev->name);
 		sc->last_led_err[1] =3D 0;
 		lmc_led_on(sc, LMC_MII16_LED1);
 	}
@@ -532,7 +535,7 @@ static int lmc_ds3_get_link_status(struct card * co=
nst sc)
 			lmc_mii_writereg(sc, 0, 18, r1);
 			printk(KERN_WARNING
 			       "%s: Red Alarm - Loss of Signal or Loss of Framing\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED3);	/* turn on red LED */
 		sc->last_led_err[3] =3D 1;
@@ -556,10 +559,11 @@ static int lmc_ds3_get_link_status(struct card * =
const sc)
 		ret =3D 0;
 		if (sc->last_led_err[0] !=3D 1) {
 			printk(KERN_WARNING
-			       "%s: AIS Alarm or XBit Error\n", sc->name);
+			       "%s: AIS Alarm or XBit Error\n",
+			       sc->netdev->name);
 			printk(KERN_WARNING
 			       "%s: Remote end has loss of signal or framing\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED0);
 		sc->last_led_err[0] =3D 1;
@@ -576,7 +580,7 @@ static int lmc_ds3_get_link_status(struct card * co=
nst sc)
 		if (sc->last_led_err[1] !=3D 1) {
 			printk(KERN_WARNING
 			       "%s: Blue Alarm - Receiving all 1's\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED1);
 		sc->last_led_err[1] =3D 1;
@@ -638,11 +642,11 @@ static void lmc_t1_set_circuit_type(struct card *=
 const sc, int ie)
 	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
 		sc->miireg16 |=3D LMC_MII16_T1_Z;
 		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
-		printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
+		printk(KERN_INFO "%s: In T1 Mode\n", sc->netdev->name);
 	} else {
 		sc->miireg16 &=3D ~LMC_MII16_T1_Z;
 		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
-		printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
+		printk(KERN_INFO "%s: In E1 Mode\n", sc->netdev->name);
 	}
=20
 	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
@@ -747,14 +751,14 @@ static int lmc_t1_get_link_status(struct card * c=
onst sc)
 		if (sc->last_led_err[1] !=3D 1) {
 			printk(KERN_WARNING
 			       "%s: Receive AIS/Blue Alarm. Far end in RED alarm\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED1);
 		sc->last_led_err[1] =3D 1;
 	} else {
 		if (sc->last_led_err[1] !=3D 0) {
 			printk(KERN_WARNING "%s: End AIS/Blue Alarm\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_off(sc, LMC_DS3_LED1);
 		sc->last_led_err[1] =3D 0;
@@ -770,14 +774,14 @@ static int lmc_t1_get_link_status(struct card * c=
onst sc)
 		ret =3D 0;
 		if (sc->last_led_err[0] !=3D 1) {
 			printk(KERN_WARNING "%s: Receive Yellow AIS Alarm\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED0);
 		sc->last_led_err[0] =3D 1;
 	} else {
 		if (sc->last_led_err[0] !=3D 0) {
 			printk(KERN_WARNING "%s: End of Yellow AIS Alarm\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_off(sc, LMC_DS3_LED0);
 		sc->last_led_err[0] =3D 0;
@@ -790,7 +794,7 @@ static int lmc_t1_get_link_status(struct card * con=
st sc)
 		if (sc->last_led_err[3] !=3D 1) {
 			printk(KERN_WARNING
 			       "%s: Local Red Alarm: Loss of Framing\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED3);
 		sc->last_led_err[3] =3D 1;
@@ -798,7 +802,7 @@ static int lmc_t1_get_link_status(struct card * con=
st sc)
 	} else {
 		if (sc->last_led_err[3] !=3D 0) {
 			printk(KERN_WARNING "%s: End Red Alarm (LOF)\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		if (!(link_status & T1F_RLOS))
 			lmc_led_off(sc, LMC_DS3_LED3);
@@ -810,7 +814,7 @@ static int lmc_t1_get_link_status(struct card * con=
st sc)
 		if (sc->last_led_err[2] !=3D 1) {
 			printk(KERN_WARNING
 			       "%s: Local Red Alarm: Loss of Signal\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		lmc_led_on(sc, LMC_DS3_LED3);
 		sc->last_led_err[2] =3D 1;
@@ -818,7 +822,7 @@ static int lmc_t1_get_link_status(struct card * con=
st sc)
 	} else {
 		if (sc->last_led_err[2] !=3D 0) {
 			printk(KERN_WARNING "%s: End Red Alarm (LOS)\n",
-			       sc->name);
+			       sc->netdev->name);
 		}
 		if (!(link_status & T1F_RLOF))
 			lmc_led_off(sc, LMC_DS3_LED3);
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 54e9b0b..f62f9a1 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -268,7 +268,6 @@ typedef struct lmc_xinfo {
=20
 /* forward decl */
 struct card {
-	char *name;
 	struct lmc_extra_statistics extra_stats;
 	struct net_device *netdev;
=20
--=20
1.7.1.1

