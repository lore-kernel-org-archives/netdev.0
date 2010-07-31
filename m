From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 03/29] LMC: Remove 3 typedefs.
Date: Sat, 31 Jul 2010 17:05:26 +0200
Message-ID: <1280588752-9340-3-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:56563 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584Ab0GaPGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:06 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/lmc.h   |   27 +++----
 drivers/net/wan/lmc/main.c  |   63 ++++++++--------
 drivers/net/wan/lmc/media.c |  178 +++++++++++++++++++++--------------=
-------
 drivers/net/wan/lmc/proto.c |   12 ++--
 drivers/net/wan/lmc/proto.h |   16 ++--
 drivers/net/wan/lmc/var.h   |   43 +++++------
 6 files changed, 168 insertions(+), 171 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index 9742650..c3464b6 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -4,23 +4,22 @@
 #include "var.h"
=20
 int lmc_probe(struct net_device *dev);
-unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned
-			 devaddr, unsigned regno);
-void lmc_mii_writereg(lmc_softc_t * const sc, unsigned devaddr,
+unsigned lmc_mii_readreg(struct card * const sc, unsigned devaddr,
+			 unsigned regno);
+void lmc_mii_writereg(struct card * const sc, unsigned devaddr,
 		      unsigned regno, unsigned data);
-void lmc_led_on(lmc_softc_t * const, u32);
-void lmc_led_off(lmc_softc_t * const, u32);
-unsigned lmc_mii_readreg(lmc_softc_t * const, unsigned, unsigned);
-void lmc_mii_writereg(lmc_softc_t * const, unsigned, unsigned, unsigne=
d);
-void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits);
-void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits);
-
+void lmc_led_on(struct card * const, u32);
+void lmc_led_off(struct card * const, u32);
+unsigned lmc_mii_readreg(struct card * const, unsigned, unsigned);
+void lmc_mii_writereg(struct card * const, unsigned, unsigned, unsigne=
d);
+void lmc_gpio_mkinput(struct card * const sc, u32 bits);
+void lmc_gpio_mkoutput(struct card * const sc, u32 bits);
 int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
=20
-extern lmc_media_t lmc_ds3_media;
-extern lmc_media_t lmc_ssi_media;
-extern lmc_media_t lmc_t1_media;
-extern lmc_media_t lmc_hssi_media;
+extern struct media lmc_ds3_media;
+extern struct media lmc_ssi_media;
+extern struct media lmc_t1_media;
+extern struct media lmc_hssi_media;
=20
 #ifdef _DBG_EVENTLOG
 static void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index e22aa0c..4fa75ad 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -94,22 +94,22 @@ static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
 static struct net_device_stats *lmc_get_stats(struct net_device *dev);
 static irqreturn_t lmc_interrupt(int irq, void *dev_instance);
-static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
,
+static void lmc_initcsrs(struct card * const sc, lmc_csrptr_t csr_base=
,
 			 size_t csr_size);
-static void lmc_softreset(lmc_softc_t * const);
+static void lmc_softreset(struct card * const);
 static void lmc_running_reset(struct net_device *dev);
 static int lmc_ifdown(struct net_device * const);
 static void lmc_watchdog(unsigned long data);
-static void lmc_reset(lmc_softc_t * const sc);
-static void lmc_dec_reset(lmc_softc_t * const sc);
+static void lmc_reset(struct card * const sc);
+static void lmc_dec_reset(struct card * const sc);
 static void lmc_driver_timeout(struct net_device *dev);
=20
 /* linux reserves 16 device specific IOCTLs.  We call them
    LMCIOC* to control various bits of our world. */
 int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
-	lmc_ctl_t ctl;
+	struct card *sc =3D dev_to_sc(dev);
+	struct control ctl;
 	int ret =3D -EOPNOTSUPP;
 	u16 regVal;
 	unsigned long flags;
@@ -123,7 +123,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		/* Return current driver state.  Since we keep this up
 		   To date internally, just copy this out to the user. */
 	case LMCIOCGINFO:
-		if (copy_to_user(ifr->ifr_data, &sc->ictl, sizeof(lmc_ctl_t)))
+		if (copy_to_user(ifr->ifr_data, &sc->ictl, sizeof(struct control)))
 			ret =3D -EFAULT;
 		else
 			ret =3D 0;
@@ -140,7 +140,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			break;
 		}
=20
-		if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
+		if (copy_from_user(&ctl, ifr->ifr_data, sizeof(struct control))) {
 			ret =3D -EFAULT;
 			break;
 		}
@@ -280,7 +280,8 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			break;
 		}
=20
-		if (copy_from_user(&ctl, ifr->ifr_data, sizeof(lmc_ctl_t))) {
+		if (copy_from_user(&ctl, ifr->ifr_data,
+				   sizeof(struct control))) {
 			ret =3D -EFAULT;
 			break;
 		}
@@ -608,7 +609,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 static void lmc_watchdog(unsigned long data)
 {
 	struct net_device *dev =3D (struct net_device *)data;
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	int link_status;
 	u32 ticks;
 	unsigned long flags;
@@ -773,7 +774,7 @@ static const struct net_device_ops lmc_ops =3D {
 static int __devinit lmc_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-	lmc_softc_t *sc;
+	struct card *sc;
 	struct net_device *dev;
 	u16 subdevice;
 	u16 AdapModelNum;
@@ -797,7 +798,7 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	/*
 	 * Allocate our own device structure
 	 */
-	sc =3D kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
+	sc =3D kzalloc(sizeof(struct card), GFP_KERNEL);
 	if (!sc) {
 		err =3D -ENOMEM;
 		goto err_kzalloc;
@@ -952,7 +953,7 @@ static void __devexit lmc_remove_one(struct pci_dev=
 *pdev)
    the addresses */
 static int lmc_open(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	int err;
=20
 	lmc_trace(dev, "lmc_open in");
@@ -1050,7 +1051,7 @@ static int lmc_open(struct net_device *dev)
=20
 static void lmc_running_reset(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
=20
 	lmc_trace(dev, "lmc_runnig_reset in");
=20
@@ -1085,7 +1086,7 @@ static void lmc_running_reset(struct net_device *=
dev)
 static int lmc_close(struct net_device *dev)
 {
 	/* not calling release_region() as we should */
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
=20
 	lmc_trace(dev, "lmc_close in");
=20
@@ -1104,7 +1105,7 @@ static int lmc_close(struct net_device *dev)
    When the interface goes down, this is called */
 static int lmc_ifdown(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	u32 csr6;
 	int i;
=20
@@ -1167,7 +1168,7 @@ static int lmc_ifdown(struct net_device *dev)
 static irqreturn_t lmc_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev =3D (struct net_device *) dev_instance;
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	u32 csr;
 	int i;
 	s32 stat;
@@ -1342,7 +1343,7 @@ lmc_int_fail_out:
 static netdev_tx_t lmc_start_xmit(struct sk_buff *skb,
 					struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	u32 flag;
 	int entry;
 	unsigned long flags;
@@ -1421,7 +1422,7 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff =
*skb,
=20
 static int lmc_rx(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	int i;
 	int rx_work_limit =3D LMC_RXDESCS;
 	unsigned int next_rx;
@@ -1606,7 +1607,7 @@ skip_out_of_mem:
=20
 static struct net_device_stats *lmc_get_stats(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	unsigned long flags;
=20
 	lmc_trace(dev, "lmc_get_stats in");
@@ -1642,7 +1643,7 @@ static void __exit exit_lmc(void)
 module_init(init_lmc);
 module_exit(exit_lmc);
=20
-unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned devaddr,
+unsigned lmc_mii_readreg(struct card * const sc, unsigned devaddr,
 			 unsigned regno)
 {
 	int i;
@@ -1684,7 +1685,7 @@ unsigned lmc_mii_readreg(lmc_softc_t * const sc, =
unsigned devaddr,
 	return (retval >> 1) & 0xffff;
 }
=20
-void lmc_mii_writereg(lmc_softc_t * const sc, unsigned devaddr, unsign=
ed regno,
+void lmc_mii_writereg(struct card * const sc, unsigned devaddr, unsign=
ed regno,
 		      unsigned data)
 {
 	int i =3D 32;
@@ -1726,7 +1727,7 @@ void lmc_mii_writereg(lmc_softc_t * const sc, uns=
igned devaddr, unsigned regno,
 	lmc_trace(sc->lmc_device, "lmc_mii_writereg out");
 }
=20
-static void lmc_softreset(lmc_softc_t * const sc)
+static void lmc_softreset(struct card * const sc)
 {
 	int i;
=20
@@ -1805,7 +1806,7 @@ static void lmc_softreset(lmc_softc_t * const sc)
 	lmc_trace(sc->lmc_device, "lmc_softreset out");
 }
=20
-void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits)
+void lmc_gpio_mkinput(struct card * const sc, u32 bits)
 {
 	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput in");
 	sc->lmc_gpio_io &=3D ~bits;
@@ -1813,7 +1814,7 @@ void lmc_gpio_mkinput(lmc_softc_t * const sc, u32=
 bits)
 	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput out");
 }
=20
-void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits)
+void lmc_gpio_mkoutput(struct card * const sc, u32 bits)
 {
 	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput in");
 	sc->lmc_gpio_io |=3D bits;
@@ -1821,7 +1822,7 @@ void lmc_gpio_mkoutput(lmc_softc_t * const sc, u3=
2 bits)
 	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput out");
 }
=20
-void lmc_led_on(lmc_softc_t * const sc, u32 led)
+void lmc_led_on(struct card * const sc, u32 led)
 {
 	lmc_trace(sc->lmc_device, "lmc_led_on in");
 	if ((~sc->lmc_miireg16) & led) { /* Already on! */
@@ -1834,7 +1835,7 @@ void lmc_led_on(lmc_softc_t * const sc, u32 led)
 	lmc_trace(sc->lmc_device, "lmc_led_on out");
 }
=20
-void lmc_led_off(lmc_softc_t * const sc, u32 led)
+void lmc_led_off(struct card * const sc, u32 led)
 {
 	lmc_trace(sc->lmc_device, "lmc_led_off in");
 	if (sc->lmc_miireg16 & led) { /* Already set don't do anything */
@@ -1847,7 +1848,7 @@ void lmc_led_off(lmc_softc_t * const sc, u32 led)
 	lmc_trace(sc->lmc_device, "lmc_led_off out");
 }
=20
-static void lmc_reset(lmc_softc_t * const sc)
+static void lmc_reset(struct card * const sc)
 {
 	lmc_trace(sc->lmc_device, "lmc_reset in");
 	sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
@@ -1877,7 +1878,7 @@ static void lmc_reset(lmc_softc_t * const sc)
 	lmc_trace(sc->lmc_device, "lmc_reset out");
 }
=20
-static void lmc_dec_reset(lmc_softc_t * const sc)
+static void lmc_dec_reset(struct card * const sc)
 {
 	u32 val;
 	lmc_trace(sc->lmc_device, "lmc_dec_reset in");
@@ -1926,7 +1927,7 @@ static void lmc_dec_reset(lmc_softc_t * const sc)
 	lmc_trace(sc->lmc_device, "lmc_dec_reset out");
 }
=20
-static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base=
,
+static void lmc_initcsrs(struct card * const sc, lmc_csrptr_t csr_base=
,
 			 size_t csr_size)
 {
 	lmc_trace(sc->lmc_device, "lmc_initcsrs in");
@@ -1951,7 +1952,7 @@ static void lmc_initcsrs(lmc_softc_t * const sc, =
lmc_csrptr_t csr_base,
=20
 static void lmc_driver_timeout(struct net_device *dev)
 {
-	lmc_softc_t *sc =3D dev_to_sc(dev);
+	struct card *sc =3D dev_to_sc(dev);
 	u32 csr6;
 	unsigned long flags;
=20
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 7a545f8..8e236b0 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -38,53 +38,53 @@
  */
=20
 /* protocol independent method. */
-static void lmc_set_protocol(lmc_softc_t * const, lmc_ctl_t *);
+static void lmc_set_protocol(struct card * const, struct control *);
=20
 /* media independent methods to check on media status, link, light LED=
s, etc. */
-static void lmc_ds3_init(lmc_softc_t * const);
-static void lmc_ds3_default(lmc_softc_t * const);
-static void lmc_ds3_set_status(lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_ds3_set_100ft(lmc_softc_t * const, int);
-static int lmc_ds3_get_link_status(lmc_softc_t * const);
-static void lmc_ds3_set_crc_length(lmc_softc_t * const, int);
-static void lmc_ds3_set_scram(lmc_softc_t * const, int);
-static void lmc_ds3_watchdog(lmc_softc_t * const);
-
-static void lmc_hssi_init(lmc_softc_t * const);
-static void lmc_hssi_default(lmc_softc_t * const);
-static void lmc_hssi_set_status(lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_hssi_set_clock(lmc_softc_t * const, int);
-static int lmc_hssi_get_link_status(lmc_softc_t * const);
-static void lmc_hssi_set_link_status(lmc_softc_t * const, int);
-static void lmc_hssi_set_crc_length(lmc_softc_t * const, int);
-static void lmc_hssi_watchdog(lmc_softc_t * const);
-
-static void lmc_ssi_init(lmc_softc_t * const);
-static void lmc_ssi_default(lmc_softc_t * const);
-static void lmc_ssi_set_status(lmc_softc_t * const, lmc_ctl_t *);
-static void lmc_ssi_set_clock(lmc_softc_t * const, int);
-static void lmc_ssi_set_speed(lmc_softc_t * const, lmc_ctl_t *);
-static int lmc_ssi_get_link_status(lmc_softc_t * const);
-static void lmc_ssi_set_link_status(lmc_softc_t * const, int);
-static void lmc_ssi_set_crc_length(lmc_softc_t * const, int);
-static void lmc_ssi_watchdog(lmc_softc_t * const);
-
-static void lmc_t1_init(lmc_softc_t * const);
-static void lmc_t1_default(lmc_softc_t * const);
-static void lmc_t1_set_status(lmc_softc_t * const, lmc_ctl_t *);
-static int lmc_t1_get_link_status(lmc_softc_t * const);
-static void lmc_t1_set_circuit_type(lmc_softc_t * const, int);
-static void lmc_t1_set_crc_length(lmc_softc_t * const, int);
-static void lmc_t1_set_clock(lmc_softc_t * const, int);
-static void lmc_t1_watchdog(lmc_softc_t * const);
-
-static void lmc_dummy_set_1(lmc_softc_t * const, int);
-static void lmc_dummy_set2_1(lmc_softc_t * const, lmc_ctl_t *);
-
-static inline void write_av9110_bit(lmc_softc_t *, int);
-static void write_av9110(lmc_softc_t *, u32, u32, u32, u32, u32);
-
-lmc_media_t lmc_ds3_media =3D {
+static void lmc_ds3_init(struct card * const);
+static void lmc_ds3_default(struct card * const);
+static void lmc_ds3_set_status(struct card * const, struct control *);
+static void lmc_ds3_set_100ft(struct card * const, int);
+static int lmc_ds3_get_link_status(struct card * const);
+static void lmc_ds3_set_crc_length(struct card * const, int);
+static void lmc_ds3_set_scram(struct card * const, int);
+static void lmc_ds3_watchdog(struct card * const);
+
+static void lmc_hssi_init(struct card * const);
+static void lmc_hssi_default(struct card * const);
+static void lmc_hssi_set_status(struct card * const, struct control *)=
;
+static void lmc_hssi_set_clock(struct card * const, int);
+static int lmc_hssi_get_link_status(struct card * const);
+static void lmc_hssi_set_link_status(struct card * const, int);
+static void lmc_hssi_set_crc_length(struct card * const, int);
+static void lmc_hssi_watchdog(struct card * const);
+
+static void lmc_ssi_init(struct card * const);
+static void lmc_ssi_default(struct card * const);
+static void lmc_ssi_set_status(struct card * const, struct control *);
+static void lmc_ssi_set_clock(struct card * const, int);
+static void lmc_ssi_set_speed(struct card * const, struct control *);
+static int lmc_ssi_get_link_status(struct card * const);
+static void lmc_ssi_set_link_status(struct card * const, int);
+static void lmc_ssi_set_crc_length(struct card * const, int);
+static void lmc_ssi_watchdog(struct card * const);
+
+static void lmc_t1_init(struct card * const);
+static void lmc_t1_default(struct card * const);
+static void lmc_t1_set_status(struct card * const, struct control *);
+static int lmc_t1_get_link_status(struct card * const);
+static void lmc_t1_set_circuit_type(struct card * const, int);
+static void lmc_t1_set_crc_length(struct card * const, int);
+static void lmc_t1_set_clock(struct card * const, int);
+static void lmc_t1_watchdog(struct card * const);
+
+static void lmc_dummy_set_1(struct card * const, int);
+static void lmc_dummy_set2_1(struct card * const, struct control *);
+
+static inline void write_av9110_bit(struct card *, int);
+static void write_av9110(struct card *, u32, u32, u32, u32, u32);
+
+struct media lmc_ds3_media =3D {
 	lmc_ds3_init,		/* special media init stuff */
 	lmc_ds3_default,	/* reset to default state */
 	lmc_ds3_set_status,	/* reset status to state provided */
@@ -99,7 +99,7 @@ lmc_media_t lmc_ds3_media =3D {
 	lmc_ds3_watchdog
 };
=20
-lmc_media_t lmc_hssi_media =3D {
+struct media lmc_hssi_media =3D {
 	lmc_hssi_init,		/* special media init stuff */
 	lmc_hssi_default,	/* reset to default state */
 	lmc_hssi_set_status,	/* reset status to state provided */
@@ -114,7 +114,7 @@ lmc_media_t lmc_hssi_media =3D {
 	lmc_hssi_watchdog
 };
=20
-lmc_media_t lmc_ssi_media =3D {
+struct media lmc_ssi_media =3D {
 	lmc_ssi_init,		/* special media init stuff */
 	lmc_ssi_default,	/* reset to default state */
 	lmc_ssi_set_status,	/* reset status to state provided */
@@ -129,7 +129,7 @@ lmc_media_t lmc_ssi_media =3D {
 	lmc_ssi_watchdog
 };
=20
-lmc_media_t lmc_t1_media =3D {
+struct media lmc_t1_media =3D {
 	lmc_t1_init,		/* special media init stuff */
 	lmc_t1_default,		/* reset to default state */
 	lmc_t1_set_status,	/* reset status to state provided */
@@ -144,23 +144,23 @@ lmc_media_t lmc_t1_media =3D {
 	lmc_t1_watchdog
 };
=20
-static void lmc_dummy_set_1(lmc_softc_t * const sc, int a)
+static void lmc_dummy_set_1(struct card * const sc, int a)
 {
 }
=20
-static void lmc_dummy_set2_1(lmc_softc_t * const sc, lmc_ctl_t * a)
+static void lmc_dummy_set2_1(struct card * const sc, struct control * =
a)
 {
 }
=20
 /* HSSI methods */
=20
-static void lmc_hssi_init(lmc_softc_t * const sc)
+static void lmc_hssi_init(struct card * const sc)
 {
 	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5200;
 	lmc_gpio_mkoutput(sc, LMC_GEP_HSSI_CLOCK);
 }
=20
-static void lmc_hssi_default(lmc_softc_t * const sc)
+static void lmc_hssi_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
@@ -171,7 +171,7 @@ static void lmc_hssi_default(lmc_softc_t * const sc=
)
=20
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
-static void lmc_hssi_set_status(lmc_softc_t * const sc, lmc_ctl_t * ct=
l)
+static void lmc_hssi_set_status(struct card * const sc, struct control=
 *ctl)
 {
 	if (ctl =3D=3D NULL) {
 		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
@@ -193,7 +193,7 @@ static void lmc_hssi_set_status(lmc_softc_t * const=
 sc, lmc_ctl_t * ctl)
 }
=20
 /* 1 =3D=3D internal, 0 =3D=3D external */
-static void lmc_hssi_set_clock(lmc_softc_t * const sc, int ie)
+static void lmc_hssi_set_clock(struct card * const sc, int ie)
 {
 	int old;
 	old =3D sc->ictl.clock_source;
@@ -215,14 +215,14 @@ static void lmc_hssi_set_clock(lmc_softc_t * cons=
t sc, int ie)
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_hssi_get_link_status(lmc_softc_t * const sc)
+static int lmc_hssi_get_link_status(struct card * const sc)
 {
 	/* We're using the same code as SSI since they're practically
 	   the same */
 	return lmc_ssi_get_link_status(sc);
 }
=20
-static void lmc_hssi_set_link_status(lmc_softc_t * const sc, int state=
)
+static void lmc_hssi_set_link_status(struct card * const sc, int state=
)
 {
 	if (state =3D=3D LMC_LINK_UP)
 		sc->lmc_miireg16 |=3D LMC_MII16_HSSI_TA;
@@ -233,7 +233,7 @@ static void lmc_hssi_set_link_status(lmc_softc_t * =
const sc, int state)
 }
=20
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_hssi_set_crc_length(lmc_softc_t * const sc, int state)
+static void lmc_hssi_set_crc_length(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
@@ -248,7 +248,7 @@ static void lmc_hssi_set_crc_length(lmc_softc_t * c=
onst sc, int state)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_hssi_watchdog(lmc_softc_t * const sc)
+static void lmc_hssi_watchdog(struct card * const sc)
 {
 	/* HSSI is blank */
 }
@@ -256,7 +256,7 @@ static void lmc_hssi_watchdog(lmc_softc_t * const s=
c)
 /* DS3 methods */
=20
 /* Set cable length */
-static void lmc_ds3_set_100ft(lmc_softc_t * const sc, int ie)
+static void lmc_ds3_set_100ft(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_CABLE_LENGTH_GT_100FT) {
 		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_ZERO;
@@ -268,7 +268,7 @@ static void lmc_ds3_set_100ft(lmc_softc_t * const s=
c, int ie)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_ds3_default(lmc_softc_t * const sc)
+static void lmc_ds3_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
@@ -280,7 +280,7 @@ static void lmc_ds3_default(lmc_softc_t * const sc)
=20
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
-static void lmc_ds3_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl=
)
+static void lmc_ds3_set_status(struct card * const sc, struct control =
*ctl)
 {
 	if (ctl =3D=3D NULL) {
 		sc->lmc_media->set_cable_length(sc, sc->ictl.cable_length);
@@ -304,7 +304,7 @@ static void lmc_ds3_set_status(lmc_softc_t * const =
sc, lmc_ctl_t * ctl)
 	lmc_set_protocol(sc, ctl);
 }
=20
-static void lmc_ds3_init(lmc_softc_t * const sc)
+static void lmc_ds3_init(struct card * const sc)
 {
 	int i;
=20
@@ -334,7 +334,7 @@ static void lmc_ds3_init(lmc_softc_t * const sc)
 }
=20
 /* 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled */
-static void lmc_ds3_set_scram(lmc_softc_t * const sc, int ie)
+static void lmc_ds3_set_scram(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_ON) {
 		sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
@@ -347,7 +347,7 @@ static void lmc_ds3_set_scram(lmc_softc_t * const s=
c, int ie)
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_ds3_get_link_status(lmc_softc_t * const sc)
+static int lmc_ds3_get_link_status(struct card * const sc)
 {
 	u16 link_status, link_status_11;
 	int ret =3D 1;
@@ -436,7 +436,7 @@ static int lmc_ds3_get_link_status(lmc_softc_t * co=
nst sc)
 }
=20
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_ds3_set_crc_length(lmc_softc_t * const sc, int state)
+static void lmc_ds3_set_crc_length(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
@@ -451,14 +451,14 @@ static void lmc_ds3_set_crc_length(lmc_softc_t * =
const sc, int state)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_ds3_watchdog(lmc_softc_t * const sc)
+static void lmc_ds3_watchdog(struct card * const sc)
 {
 }
=20
=20
 /* SSI methods */
=20
-static void lmc_ssi_init(lmc_softc_t * const sc)
+static void lmc_ssi_init(struct card * const sc)
 {
 	u16 mii17;
 	int cable;
@@ -473,7 +473,7 @@ static void lmc_ssi_init(lmc_softc_t * const sc)
 	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
 }
=20
-static void lmc_ssi_default(lmc_softc_t * const sc)
+static void lmc_ssi_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
@@ -488,7 +488,7 @@ static void lmc_ssi_default(lmc_softc_t * const sc)
=20
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
-static void lmc_ssi_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl=
)
+static void lmc_ssi_set_status(struct card * const sc, struct control =
*ctl)
 {
 	if (ctl =3D=3D NULL) {
 		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
@@ -515,7 +515,7 @@ static void lmc_ssi_set_status(lmc_softc_t * const =
sc, lmc_ctl_t * ctl)
 }
=20
 /* 1 =3D=3D internal, 0 =3D=3D external */
-static void lmc_ssi_set_clock(lmc_softc_t * const sc, int ie)
+static void lmc_ssi_set_clock(struct card * const sc, int ie)
 {
 	int old;
 	old =3D ie;
@@ -536,9 +536,9 @@ static void lmc_ssi_set_clock(lmc_softc_t * const s=
c, int ie)
 	}
 }
=20
-static void lmc_ssi_set_speed(lmc_softc_t * const sc, lmc_ctl_t * ctl)
+static void lmc_ssi_set_speed(struct card * const sc, struct control *=
ctl)
 {
-	lmc_ctl_t *ictl =3D &sc->ictl;
+	struct control *ictl =3D &sc->ictl;
 	lmc_av9110_t *av;
=20
 	/* original settings for clock rate of 100 Khz (8,25,0,0,2) were
@@ -570,7 +570,7 @@ static void lmc_ssi_set_speed(lmc_softc_t * const s=
c, lmc_ctl_t * ctl)
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_ssi_get_link_status(lmc_softc_t * const sc)
+static int lmc_ssi_get_link_status(struct card * const sc)
 {
 	u16 link_status;
 	u32 ticks;
@@ -649,7 +649,7 @@ static int lmc_ssi_get_link_status(lmc_softc_t * co=
nst sc)
 	return ret;
 }
=20
-static void lmc_ssi_set_link_status(lmc_softc_t * const sc, int state)
+static void lmc_ssi_set_link_status(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_LINK_UP) {
 		sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
@@ -666,7 +666,7 @@ static void lmc_ssi_set_link_status(lmc_softc_t * c=
onst sc, int state)
 }
=20
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_ssi_set_crc_length(lmc_softc_t * const sc, int state)
+static void lmc_ssi_set_crc_length(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
@@ -685,7 +685,7 @@ static void lmc_ssi_set_crc_length(lmc_softc_t * co=
nst sc, int state)
 }
=20
 /* These are bits to program the ssi frequency generator */
-static inline void write_av9110_bit(lmc_softc_t *sc, int c)
+static inline void write_av9110_bit(struct card *sc, int c)
 {
 	/* set the data bit as we need it. */
 	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
@@ -704,7 +704,7 @@ static inline void write_av9110_bit(lmc_softc_t *sc=
, int c)
 	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
 }
=20
-static void write_av9110(lmc_softc_t *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
+static void write_av9110(struct card *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
 {
 	int i;
=20
@@ -743,7 +743,7 @@ static void write_av9110(lmc_softc_t *sc, u32 n, u3=
2 m, u32 v, u32 x, u32 r)
 			      LMC_GEP_SSI_GENERATOR));
 }
=20
-static void lmc_ssi_watchdog(lmc_softc_t * const sc)
+static void lmc_ssi_watchdog(struct card * const sc)
 {
 	u16 mii17 =3D lmc_mii_readreg(sc, 0, 17);
 	if (((mii17 >> 3) & 7) =3D=3D 7)
@@ -756,14 +756,14 @@ static void lmc_ssi_watchdog(lmc_softc_t * const =
sc)
=20
 /* The framer regs are multiplexed through MII regs 17 & 18 write the =
register
    address to MII reg 17 and the data to MII reg 18. */
-static void lmc_t1_write(lmc_softc_t * const sc, int a, int d)
+static void lmc_t1_write(struct card * const sc, int a, int d)
 {
 	lmc_mii_writereg(sc, 0, 17, a);
 	lmc_mii_writereg(sc, 0, 18, d);
 }
=20
 /* Save a warning
-static int lmc_t1_read(lmc_softc_t * const sc, int a)
+static int lmc_t1_read(struct card * const sc, int a)
 {
 	lmc_mii_writereg(sc, 0, 17, a);
 	return lmc_mii_readreg(sc, 0, 18);
@@ -771,7 +771,7 @@ static int lmc_t1_read(lmc_softc_t * const sc, int =
a)
 */
=20
=20
-static void lmc_t1_init(lmc_softc_t * const sc)
+static void lmc_t1_init(struct card * const sc)
 {
 	u16 mii16;
 	int i;
@@ -830,7 +830,7 @@ static void lmc_t1_init(lmc_softc_t * const sc)
 	sc->lmc_miireg16 =3D mii16;
 }
=20
-static void lmc_t1_default(lmc_softc_t * const sc)
+static void lmc_t1_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
 	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
@@ -841,7 +841,7 @@ static void lmc_t1_default(lmc_softc_t * const sc)
 }
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
-static void lmc_t1_set_status(lmc_softc_t * const sc, lmc_ctl_t * ctl)
+static void lmc_t1_set_status(struct card * const sc, struct control *=
ctl)
 {
 	if (ctl =3D=3D NULL) {
 		sc->lmc_media->set_circuit_type(sc, sc->ictl.circuit_type);
@@ -860,7 +860,7 @@ static void lmc_t1_set_status(lmc_softc_t * const s=
c, lmc_ctl_t * ctl)
 }
=20
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_t1_get_link_status(lmc_softc_t * const sc)
+static int lmc_t1_get_link_status(struct card * const sc)
 {
 	u16 link_status;
 	int ret =3D 1;
@@ -970,7 +970,7 @@ static int lmc_t1_get_link_status(lmc_softc_t * con=
st sc)
 }
=20
 /* 1 =3D=3D T1 Circuit Type , 0 =3D=3D E1 Circuit Type */
-static void lmc_t1_set_circuit_type(lmc_softc_t * const sc, int ie)
+static void lmc_t1_set_circuit_type(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
 		sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
@@ -986,7 +986,7 @@ static void lmc_t1_set_circuit_type(lmc_softc_t * c=
onst sc, int ie)
 }
=20
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_t1_set_crc_length(lmc_softc_t * const sc, int state)
+static void lmc_t1_set_crc_length(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
@@ -1005,7 +1005,7 @@ static void lmc_t1_set_crc_length(lmc_softc_t * c=
onst sc, int state)
 }
=20
 /* 1 =3D=3D internal, 0 =3D=3D external */
-static void lmc_t1_set_clock(lmc_softc_t * const sc, int ie)
+static void lmc_t1_set_clock(struct card * const sc, int ie)
 {
 	int old;
 	old =3D ie;
@@ -1026,11 +1026,11 @@ static void lmc_t1_set_clock(lmc_softc_t * cons=
t sc, int ie)
 	}
 }
=20
-static void lmc_t1_watchdog(lmc_softc_t * const sc)
+static void lmc_t1_watchdog(struct card * const sc)
 {
 }
=20
-static void lmc_set_protocol(lmc_softc_t * const sc, lmc_ctl_t * ctl)
+static void lmc_set_protocol(struct card * const sc, struct control *c=
tl)
 {
 	if (!ctl)
 		sc->ictl.keepalive_onoff =3D LMC_CTL_ON;
diff --git a/drivers/net/wan/lmc/proto.c b/drivers/net/wan/lmc/proto.c
index d6c0cc2..547c8d8 100644
--- a/drivers/net/wan/lmc/proto.c
+++ b/drivers/net/wan/lmc/proto.c
@@ -46,7 +46,7 @@
 #include "ioctl.h"
 #include "proto.h"
=20
-void lmc_proto_attach(lmc_softc_t *sc)
+void lmc_proto_attach(struct card *sc)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_attach in");
 	if (sc->if_type =3D=3D LMC_NET) {
@@ -59,7 +59,7 @@ void lmc_proto_attach(lmc_softc_t *sc)
 	lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
=20
-int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd)
+int lmc_proto_ioctl(struct card *sc, struct ifreq *ifr, int cmd)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_ioctl");
 	if (sc->if_type =3D=3D LMC_PPP)
@@ -67,7 +67,7 @@ int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *if=
r, int cmd)
 	return -EOPNOTSUPP;
 }
=20
-int lmc_proto_open(lmc_softc_t *sc)
+int lmc_proto_open(struct card *sc)
 {
 	int ret =3D 0;
=20
@@ -84,7 +84,7 @@ int lmc_proto_open(lmc_softc_t *sc)
 	return ret;
 }
=20
-void lmc_proto_close(lmc_softc_t *sc)
+void lmc_proto_close(struct card *sc)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_close in");
=20
@@ -94,7 +94,7 @@ void lmc_proto_close(lmc_softc_t *sc)
 	lmc_trace(sc->lmc_device, "lmc_proto_close out");
 }
=20
-__be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb)
+__be16 lmc_proto_type(struct card *sc, struct sk_buff *skb)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_type in");
 	switch (sc->if_type) {
@@ -118,7 +118,7 @@ __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_bu=
ff *skb)
=20
 }
=20
-void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb)
+void lmc_proto_netif(struct card *sc, struct sk_buff *skb)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_netif in");
 	switch (sc->if_type) {
diff --git a/drivers/net/wan/lmc/proto.h b/drivers/net/wan/lmc/proto.h
index 662148c..23094ed 100644
--- a/drivers/net/wan/lmc/proto.h
+++ b/drivers/net/wan/lmc/proto.h
@@ -3,16 +3,16 @@
=20
 #include <linux/hdlc.h>
=20
-void lmc_proto_attach(lmc_softc_t *sc);
-int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd);
-int lmc_proto_open(lmc_softc_t *sc);
-void lmc_proto_close(lmc_softc_t *sc);
-__be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb);
-void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb);
+void lmc_proto_attach(struct card *sc);
+int lmc_proto_ioctl(struct card *sc, struct ifreq *ifr, int cmd);
+int lmc_proto_open(struct card *sc);
+void lmc_proto_close(struct card *sc);
+__be16 lmc_proto_type(struct card *sc, struct sk_buff *skb);
+void lmc_proto_netif(struct card *sc, struct sk_buff *skb);
=20
-static inline lmc_softc_t* dev_to_sc(struct net_device *dev)
+static inline struct card* dev_to_sc(struct net_device *dev)
 {
-	return (lmc_softc_t *)dev_to_hdlc(dev)->priv;
+	return (struct card *)dev_to_hdlc(dev)->priv;
 }
=20
 #endif
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 9b14979..e9aad37 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -19,10 +19,6 @@
=20
 /* basic definitions used in lmc include files */
=20
-typedef struct lmc___softc	lmc_softc_t;
-typedef struct lmc___media	lmc_media_t;
-typedef struct lmc___ctl	lmc_ctl_t;
-
 #define lmc_csrptr_t		unsigned long
=20
 #define LMC_REG_RANGE		0x80
@@ -137,6 +133,8 @@ struct lmc_regfile_t {
 				   LMC_RDES_REPORT_ON_MII_ERR |	 \
 				   LMC_RDES_COLLISION_SEEN))
=20
+struct card;
+
 /* Ioctl info */
=20
 typedef struct {
@@ -150,7 +148,7 @@ typedef struct {
 } lmc_av9110_t;
=20
 /* Common structure passed to the ioctl code. */
-struct lmc___ctl {
+struct control {
 	u32 cardtype;
 	u32 clock_source;		/* HSSI, T1 */
 	u32 clock_rate;			/* T1 */
@@ -163,7 +161,7 @@ struct lmc___ctl {
 	union {
 		lmc_av9110_t ssi;
 	} cardspec;
-	u32	circuit_type;		/* T1 or E1 */
+	u32 circuit_type;		/* T1 or E1 */
 };
=20
=20
@@ -188,19 +186,19 @@ struct tulip_desc_t {
 };
=20
 /* media independent methods to check on media status, link, light LED=
s, etc. */
-struct lmc___media {
-	void (* init)(lmc_softc_t * const);
-	void (* defaults)(lmc_softc_t * const);
-	void (* set_status)(lmc_softc_t * const, lmc_ctl_t *);
-	void (* set_clock_source)(lmc_softc_t * const, int);
-	void (* set_speed)(lmc_softc_t * const, lmc_ctl_t *);
-	void (* set_cable_length)(lmc_softc_t * const, int);
-	void (* set_scrambler)(lmc_softc_t * const, int);
-	int (* get_link_status)(lmc_softc_t * const);
-	void (* set_link_status)(lmc_softc_t * const, int);
-	void (* set_crc_length)(lmc_softc_t * const, int);
-	void (* set_circuit_type)(lmc_softc_t * const, int);
-	void (* watchdog)(lmc_softc_t * const);
+struct media {
+	void (* init)(struct card * const);
+	void (* defaults)(struct card * const);
+	void (* set_status)(struct card * const, struct control *);
+	void (* set_clock_source)(struct card * const, int);
+	void (* set_speed)(struct card * const, struct control *);
+	void (* set_cable_length)(struct card * const, int);
+	void (* set_scrambler)(struct card * const, int);
+	int (* get_link_status)(struct card * const);
+	void (* set_link_status)(struct card * const, int);
+	void (* set_crc_length)(struct card * const, int);
+	void (* set_circuit_type)(struct card * const, int);
+	void (* watchdog)(struct card * const);
 };
=20
 #define STATCHECK 0xBEEFCAFE
@@ -271,7 +269,7 @@ typedef struct lmc_xinfo {
=20
=20
 /* forward decl */
-struct lmc___softc {
+struct card {
 	char *name;
 	u8 board_idx;
 	struct lmc_extra_statistics extra_stats;
@@ -301,9 +299,9 @@ struct lmc___softc {
 	int last_link_status;
 	int lmc_cardtype;
 	u32 last_frameerr;
-	lmc_media_t *lmc_media;
+	struct media *lmc_media;
 	struct timer_list timer;
-	lmc_ctl_t ictl;
+	struct control ictl;
 	u32 TxDescriptControlInit;
=20
 	int tx_TimeoutInd;		/* additional driver state */
@@ -328,7 +326,6 @@ struct lmc___softc {
 	u8 failed_ring;			/* Failure cases */
 	u8 failed_recv_alloc;
=20
-
 	u32 check;			/* Structure check */
 };
=20
--=20
1.7.1.1

