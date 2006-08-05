From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] Use IRQF_SHARED instead of SA_SHIRQ
Date: Sat, 5 Aug 2006 00:57:04 -0700
Message-ID: <200608050057.09787.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1802296.J0iMF82RnO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:57002 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1422756AbWHEH5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:57:13 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1802296.J0iMF82RnO
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Use IRQF_SHARED instead of SA_SHIRQ

This patch switches all instances of SA_SHIRQ to IRQF_SHARED for drivers in=
=20
the drivers/net/wireless/d80211 directory. According to=20
feature-removal-schedule.txt, the interrupt related SA_* flags are obsolete=
=20
and should be replaced by the appropriate IRQF_* version before January 200=
7.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c      |    2 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 339b69c..dcabeab 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -1627,7 +1627,7 @@ static int adm8211_open(struct net_devic
 	adm8211_rf_set_channel(dev, priv->channel);
=20
 	retval =3D request_irq(dev->irq, &adm8211_interrupt,
=2D			     SA_SHIRQ, dev->name, dev);
+			     IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		printk(KERN_ERR "%s: failed to register IRQ handler\n",
 		       dev->name);
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c=20
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 59d137b..6366020 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -2295,7 +2295,7 @@ #ifdef CONFIG_BCM947XX
 	}
 #endif
 	err =3D request_irq(bcm->irq, bcm43xx_interrupt_handler,
=2D			  SA_SHIRQ, KBUILD_MODNAME, bcm);
+			  IRQF_SHARED, KBUILD_MODNAME, bcm);
 	if (err)
 		printk(KERN_ERR PFX "Cannot register IRQ%d\n", bcm->irq);
=20
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 709cdbf..16e78b9 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1356,7 +1356,7 @@ static int rt2400pci_initialize(struct r
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2400pci_interrupt,
=2D		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 8a22968..f79d386 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1476,7 +1476,7 @@ static int rt2500pci_initialize(struct r
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2500pci_interrupt,
=2D		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 8bb9de9..b28e113 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1902,7 +1902,7 @@ static int rt61pci_initialize(struct rt2
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt61pci_interrupt,
=2D		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;

--nextPart1802296.J0iMF82RnO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE1E9VT3Oqt9AH4aERAqIbAJ4syGrTB7ZHBt99fEWfj4L+3/NTlgCeNtcB
kG9Uy6MatG0zzq4IyqnuFX0=
=tl9o
-----END PGP SIGNATURE-----

--nextPart1802296.J0iMF82RnO--
