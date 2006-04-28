From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rt2x00: Compile fix and kernel version cleanup
Date: Fri, 28 Apr 2006 20:52:41 +0200
Message-ID: <200604282052.44767.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2696596.fLWvezh9W7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:818 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751438AbWD1Svg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 14:51:36 -0400
Received: by nproxy.gmail.com with SMTP id n29so1637804nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 11:51:34 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2696596.fLWvezh9W7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

During CVS merge I noticed several compilation errors have sneaked
into the git version of rt2x00.
=2D PRIO_ENTRIES define has been removed, TX_ENTRIES should be used
=2D poll_delay module argument is of the type short
=2D Remove LINUX_VERSION_CODE checks.
=2D Fix missing byteordering type
=2D Fix typo in usb_device

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-28 20:49:32.000000000 +0200
+++ wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	=
2006-04-28 20:50:40.000000000 +0200
@@ -1239,7 +1239,7 @@ rt2400pci_allocate_rings(struct rt2x00_p
 		ATIM_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2400pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_PRIO], rt2400pci_txdone,
=2D		PRIO_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
+		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2400pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_BEACON], rt2400pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
@@ -2729,14 +2729,12 @@ MODULE_PARM_DESC(debug, "Set this parame
 #endif /* CONFIG_RT2400PCI_DEBUG */
=20
 #ifdef CONFIG_RT2400PCI_BUTTON
=2Dmodule_param_named(poll_delay, rt2x00_poll_delay, int, S_IRUGO);
+module_param_named(poll_delay, rt2x00_poll_delay, short, S_IRUGO);
 MODULE_PARM_DESC(debug, "Delay between WiFi button pollings (in 100ms).");
 #endif /* CONFIG_RT2400PCI_BUTTON */
=20
 static struct pci_driver rt2400pci_driver =3D {
=2D#if LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 14)
 	.owner		=3D THIS_MODULE,
=2D#endif /* LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 14) */
 	.name		=3D DRV_NAME,
 	.id_table	=3D rt2400pci_device_table,
 	.probe		=3D rt2400pci_probe,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-28 20:49:45.000000000 +0200
+++ wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	=
2006-04-28 20:50:39.000000000 +0200
@@ -1328,7 +1328,7 @@ rt2500pci_allocate_rings(struct rt2x00_p
 		ATIM_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_PRIO], rt2500pci_txdone,
=2D		PRIO_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
+		TX_ENTRIES, DATA_FRAME_SIZE, sizeof(struct txd))
 	|| rt2500pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_BEACON], rt2500pci_beacondone,
 		BEACON_ENTRIES, MGMT_FRAME_SIZE, sizeof(struct txd))) {
@@ -3032,14 +3032,12 @@ MODULE_PARM_DESC(debug, "Set this parame
 #endif /* CONFIG_RT2500PCI_DEBUG */
=20
 #ifdef CONFIG_RT2500PCI_BUTTON
=2Dmodule_param_named(poll_delay, rt2x00_poll_delay, int, S_IRUGO);
+module_param_named(poll_delay, rt2x00_poll_delay, short, S_IRUGO);
 MODULE_PARM_DESC(debug, "Delay between WiFi button pollings (in 100ms).");
 #endif /* CONFIG_RT2500PCI_BUTTON */
=20
 static struct pci_driver rt2500pci_driver =3D {
=2D#if LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 14)
 	.owner		=3D THIS_MODULE,
=2D#endif /* LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 14) */
 	.name		=3D DRV_NAME,
 	.id_table	=3D rt2500pci_device_table,
 	.probe		=3D rt2500pci_probe,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-28 15:58:29.000000000 +0200
+++ wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	=
2006-04-28 20:28:58.000000000 +0200
@@ -1005,7 +1005,7 @@ struct txd{
 	__le32				word1;
 #define TXD_W1_BUFFER_ADDRESS		FIELD32(0xffffffff)
=20
=2D	u32				word2;
+	__le32				word2;
 #define TXD_W2_IV_OFFSET		FIELD32(0x0000003f)
 #define TXD_W2_AIFS			FIELD32(0x000000c0)
 #define TXD_W2_CWMIN			FIELD32(0x00000f00)
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-28 20:49:59.000000000 +0200
+++ wireless-dev-rt2x00-cvs/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	=
2006-04-28 20:50:39.000000000 +0200
@@ -1362,7 +1362,7 @@ rt2500usb_tx(struct net_device *net_dev,
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	struct usb_devive	*usb_dev =3D
+	struct usb_device	*usb_dev =3D
 		interface_to_usbdev(rt2x00usb->usb_intf);
 	struct data_ring	*ring;
 	struct data_entry	*entry;
@@ -1844,7 +1844,7 @@ rt2500usb_beacon_update(struct net_devic
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	struct usb_devive	*usb_dev =3D
+	struct usb_device	*usb_dev =3D
 		interface_to_usbdev(rt2x00usb->usb_intf);
 	struct data_entry	*entry;
=20
@@ -2074,7 +2074,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 			channels[counter].val =3D vals[counter];
 	}
=20
=2D		/*
+	/*
 	 * Set TX power, each EEPROM TXpower entry
 	 * contains the TXpower value for 2 channels.
 	 */
@@ -2628,9 +2628,7 @@ MODULE_PARM_DESC(debug, "Set this parame
 #endif /* CONFIG_RT2500USB_DEBUG */
=20
 static struct usb_driver rt2500usb_driver =3D {
=2D#if LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 15)
 	.owner		=3D THIS_MODULE,
=2D#endif /* LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 15) */
 	.name		=3D DRV_NAME,
 	.id_table	=3D rt2500usb_device_table,
 	.probe		=3D rt2500usb_probe,

--nextPart2696596.fLWvezh9W7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUmR8aqndE37Em0gRAsyhAKC0tCKpwH9cyu013WHdL5bLB3vSFACguvhd
vG8jRcFPVx744nClG2WHvVA=
=1Gym
-----END PGP SIGNATURE-----

--nextPart2696596.fLWvezh9W7--
