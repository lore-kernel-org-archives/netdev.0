From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] Remove struct pt_regs * from d80211 drivers
Date: Fri, 13 Oct 2006 14:05:33 -0400
Message-ID: <200610131405.54929.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2372471.FB3DQ1XA8j";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:58232 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1751783AbWJMSKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 14:10:20 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2372471.FB3DQ1XA8j
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Remove struct pt_regs * from d80211 drivers

This patch will be necessary once wireless-dev pulls the 2.6.19-rc2 changes=
=20
which include the removal of the struct pt_regs * argument in interrupt=20
handler callbacks.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c      |    3 +--
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt61pci.h       |    3 +--
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |    2 +-
 drivers/net/wireless/d80211/rt2x00/rt73usb.h       |    2 +-
 12 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 5522e15..38d483a 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -568,8 +568,7 @@ static void adm8211_interrupt_rci(struct
 }
=20
=20
=2Dstatic irqreturn_t adm8211_interrupt(int irq, void *dev_id,
=2D				     struct pt_regs *regs)
+static irqreturn_t adm8211_interrupt(int irq, void *dev_id)
 {
 #define ADM8211_INT(x) if (unlikely(stsr & ADM8211_STSR_ ## x))=20
printk(KERN_DEBUG "%s: " #x "\n", dev->name)
=20
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c=20
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 82f1fd1..9ae69f8 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1619,7 +1619,7 @@ static void bcm43xx_interrupt_ack(struct
 }
=20
 /* Interrupt handler top-half */
=2Dstatic irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id, stru=
ct=20
pt_regs *regs)
+static irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id)
 {
 	irqreturn_t ret =3D IRQ_HANDLED;
 	struct bcm43xx_private *bcm =3D dev_id;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index a46b8b8..bdc57fc 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1803,8 +1803,7 @@ static void rt2400pci_txdone(void *data)
 			entry->tx_status.control.queue);
 }
=20
=2Dstatic irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs)
+static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance)
 {
 	struct rt2x00_dev *rt2x00dev =3D dev_instance;
 	u32 reg;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h=20
b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
index a991b59..c120a4f 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
@@ -943,7 +943,6 @@ static void rt2400pci_disable_radio(stru
 static void rt2400pci_beacondone(void *data);
 static void rt2400pci_rxdone(void *data);
 static void rt2400pci_txdone(void *data);
=2Dstatic irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs);
+static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance);
=20
 #endif /* RT2400PCI_H */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index c08b076..d350935 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1952,8 +1952,7 @@ static void rt2500pci_txdone(void *data)
 			entry->tx_status.control.queue);
 }
=20
=2Dstatic irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs)
+static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance)
 {
 	struct rt2x00_dev *rt2x00dev =3D dev_instance;
 	u32 reg;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h=20
b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
index fb44881..fe832d6 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
@@ -1204,7 +1204,6 @@ static void rt2500pci_disable_radio(stru
 static void rt2500pci_beacondone(void *data);
 static void rt2500pci_rxdone(void *data);
 static void rt2500pci_txdone(void *data);
=2Dstatic irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs);
+static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance);
=20
 #endif /* RT2500PCI_H */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c=20
b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 5d119cd..4f7dacd 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1733,7 +1733,7 @@ static void rt2500usb_txdone(void *data)
 			entry->tx_status.control.queue);
 }
=20
=2Dstatic void rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs)
+static void rt2500usb_interrupt(struct urb *urb)
 {
 	struct data_entry *entry =3D (struct data_entry*)urb->context;
 	struct rt2x00_dev *rt2x00dev =3D ieee80211_dev_hw_data(
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h=20
b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
index 7babcb6..cd8cad0 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
@@ -725,6 +725,6 @@ static void rt2500usb_disable_radio(stru
 static void rt2500usb_beacondone(void *data);
 static void rt2500usb_rxdone(void *data);
 static void rt2500usb_txdone(void *data);
=2Dstatic void rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs);
+static void rt2500usb_interrupt(struct urb *urb);
=20
 #endif /* RT2500USB_H */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c=20
b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 3e1a702..3751e61 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2439,8 +2439,7 @@ static void rt61pci_txdone(void *data)
 		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 }
=20
=2Dstatic irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs)
+static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance)
 {
 	struct rt2x00_dev *rt2x00dev =3D dev_instance;
 	u32 reg;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.h=20
b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
index 77b867d..9d1e6a3 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
@@ -1410,7 +1410,6 @@ static void rt61pci_disable_radio(struct
 static void rt61pci_beacondone(void *data);
 static void rt61pci_rxdone(void *data);
 static void rt61pci_txdone(void *data);
=2Dstatic irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
=2D	struct pt_regs *regs);
+static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance);
=20
 #endif /* RT61PCI_H */
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c=20
b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index a3b0996..72da71b 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -2025,7 +2025,7 @@ static void rt73usb_txdone(void *data)
 			entry->tx_status.control.queue);
 }
=20
=2Dstatic void rt73usb_interrupt(struct urb *urb, struct pt_regs *regs)
+static void rt73usb_interrupt(struct urb *urb)
 {
 	struct data_entry *entry =3D (struct data_entry*)urb->context;
 	struct rt2x00_dev *rt2x00dev =3D ieee80211_dev_hw_data(
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.h=20
b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
index cc1013c..257dc7b 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt73usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
@@ -989,6 +989,6 @@ static void rt73usb_disable_radio(struct
 static void rt73usb_beacondone(void *data);
 static void rt73usb_rxdone(void *data);
 static void rt73usb_txdone(void *data);
=2Dstatic void rt73usb_interrupt(struct urb *urb, struct pt_regs *regs);
+static void rt73usb_interrupt(struct urb *urb);
=20
 #endif /* RT73USB_H */

--nextPart2372471.FB3DQ1XA8j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFL9WCT3Oqt9AH4aERAkuoAKCObf9nBZDxoYQpgC8u7xu+EcZMJACfXgDf
GhqK/AEjBmHlzcYbhkIMSnU=
=lgxB
-----END PGP SIGNATURE-----

--nextPart2372471.FB3DQ1XA8j--
