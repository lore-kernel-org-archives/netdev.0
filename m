From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 25/32] rt2x00: Add flag handlers
Date: Fri, 28 Apr 2006 00:03:16 +0200
Message-ID: <200604280003.16688.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4027525.EqVVj7vATB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751800AbWD0WCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:17 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:17 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4027525.EqVVj7vATB
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Add flag handlers to set the state and capabilities of
the driver.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:56:05.000000000 +0200
@@ -1099,7 +1099,7 @@ rt2400pci_allocate_rings(struct rt2x00_p
 		return -ENOMEM;
 	}
=20
=2D	rt2x00pci->atim_available =3D 1;
+	SET_FLAG(rt2x00pci, ATIM_AVAILABLE);
=20
 	if (rt2400pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_RX], rt2400pci_rxdone,
@@ -1549,6 +1549,8 @@ rt2400pci_open(struct net_device *net_de
 	rt2x00_set_field32(&reg, CSR8_RXDONE, 0);
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
=20
+	SET_FLAG(rt2x00pci, RADIO_ENABLED);
+
 	return 0;
=20
 exit_fail:
@@ -1563,6 +1565,8 @@ rt2400pci_stop(struct net_device *net_de
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
 	u32			reg;
=20
+	CLEAR_FLAG(rt2x00pci, RADIO_ENABLED);
+
 	rt2x00_register_write(rt2x00pci, PWRCSR0, 0);
=20
 	/*
@@ -1972,16 +1976,11 @@ rt2400pci_init_eeprom(struct rt2x00_pci=20
 	rt2x00pci->led_mode =3D rt2x00_get_field16(eeprom,
 				EEPROM_ANTENNA_LED_MODE);
=20
=2D#ifdef CONFIG_RT2400PCI_BUTTON
 	/*
 	 * 6 - Detect if this device has an hardware controlled radio.
=2D	 * If this device is not hardware controlled, disable polling timer.
 	 */
 	if (rt2x00_get_field16(eeprom, EEPROM_ANTENNA_HARDWARE_RADIO))
=2D		rt2x00pci->button_status =3D BUTTON_STATUS_OFF;
=2D	else
=2D		rt2x00pci->button_status =3D BUTTON_STATUS_UNAVAILABLE;
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
+		SET_FLAG(rt2x00pci, HARDWARE_BUTTON);
=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 21:56:05.000000000 +0200
@@ -868,6 +868,11 @@ struct data_entry{
  * Device specific structure.
  */
 struct rt2x00_pci{
+	/*
+	 * Device flags.
+	 */
+	unsigned int				flags;
+
 #ifdef CONFIG_RT2400PCI_BUTTON
 	/*
 	 * ACPI device for generation of ACPI events.
@@ -935,8 +940,6 @@ struct rt2x00_pci{
 	 */
 	int					false_cca;
=20
=2D	int					atim_available;
=2D
 	/*
 	 * EEPROM bus width.
 	 */
@@ -987,7 +990,7 @@ rt2x00pci_get_ring(struct rt2x00_pci *rt
 {
 	u8					atim;
=20
=2D	atim =3D rt2x00pci->atim_available;
+	atim =3D GET_FLAG(rt2x00pci, ATIM_AVAILABLE);
=20
 	/*
 	 * Check if the rings have been allocated.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:56:05.000000000 +0200
@@ -1180,7 +1180,7 @@ rt2500pci_allocate_rings(struct rt2x00_p
 		return -ENOMEM;
 	}
=20
=2D	rt2x00pci->atim_available =3D 1;
+	SET_FLAG(rt2x00pci, ATIM_AVAILABLE);
=20
 	if (rt2500pci_alloc_ring(
 		rt2x00pci, &rt2x00pci->ring[RING_RX], rt2500pci_rxdone,
@@ -1657,6 +1657,8 @@ rt2500pci_open(struct net_device *net_de
 	rt2x00_set_field32(&reg, CSR8_RXDONE, 0);
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
=20
+	SET_FLAG(rt2x00pci, RADIO_ENABLED);
+
 	return 0;
=20
 exit_fail:
@@ -1671,6 +1673,8 @@ rt2500pci_stop(struct net_device *net_de
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
 	u32			reg;
=20
+	CLEAR_FLAG(rt2x00pci, RADIO_ENABLED);
+
 	rt2x00_register_write(rt2x00pci, PWRCSR0, 0);
=20
 	/*
@@ -1929,7 +1933,7 @@ rt2500pci_conf_tx(struct net_device *net
=20
 	/*
 	 * The passed variables are stored as real value ((2^n)-1).
=2D	 * RT2400 registers require to know the bit number 'n'.
+	 * RT2500 registers require to know the bit number 'n'.
 	 */
 	if (params->cw_min)
 		ring->tx_params.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
@@ -2075,16 +2079,11 @@ rt2500pci_init_eeprom(struct rt2x00_pci=20
 	rt2x00pci->led_mode =3D rt2x00_get_field16(eeprom,
 				EEPROM_ANTENNA_LED_MODE);
=20
=2D#ifdef CONFIG_RT2500PCI_BUTTON
 	/*
 	 * 6 - Detect if this device has an hardware controlled radio.
=2D	 * If this device is not hardware controlled, disable polling timer.
 	 */
 	if (rt2x00_get_field16(eeprom, EEPROM_ANTENNA_HARDWARE_RADIO))
=2D		rt2x00pci->button_status =3D BUTTON_STATUS_OFF;
=2D	else
=2D		rt2x00pci->button_status =3D BUTTON_STATUS_UNAVAILABLE;
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
+		SET_FLAG(rt2x00pci, HARDWARE_BUTTON);
=20
 	/*
 	 * 7 - Read BBP data from EEPROM and store in private structure.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 21:56:05.000000000 +0200
@@ -1137,6 +1137,11 @@ struct data_entry{
  * Device specific structure.
  */
 struct rt2x00_pci{
+	/*
+	 * Device flags.
+	 */
+	unsigned int				flags;
+
 #ifdef CONFIG_RT2500PCI_BUTTON
 	/*
 	 * ACPI device for generation of ACPI events.
@@ -1200,8 +1205,6 @@ struct rt2x00_pci{
 	 */
 	struct ieee80211_rx_status		rx_params;
=20
=2D	u16					atim_available;
=2D
 	/*
 	 * EEPROM bus width.
 	 */
@@ -1252,7 +1255,7 @@ rt2x00pci_get_ring(struct rt2x00_pci *rt
 {
 	u8					atim;
=20
=2D	atim =3D rt2x00pci->atim_available;
+	atim =3D GET_FLAG(rt2x00pci, ATIM_AVAILABLE);
=20
 	/*
 	 * Check if the rings have been allocated.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:55:14.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:56:05.000000000 +0200
@@ -742,10 +742,14 @@ rt2500usb_rxdone(void *data)
 		entry =3D rt2x00_get_data_entry(ring);
 		rxd =3D rt2x00usb_rxdesc_addr(entry);
=20
+		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
+			break;
+
 		/*
=2D		* There has been a problem. Ignore packet.
=2D		*/
+		 * There has been a problem. Ignore packet.
+		 */
 		if (entry->urb->status) {
+			SET_FLAG(entry, ENTRY_OWNER_NIC);
 			usb_submit_urb(entry->urb, GFP_ATOMIC);
 			rt2x00_ring_index_inc(ring);
 			continue;
@@ -782,6 +786,7 @@ rt2500usb_rxdone(void *data)
 			total_rssi +=3D rt2x00usb->rx_params.ssi;
 		}
=20
+		SET_FLAG(entry, ENTRY_OWNER_NIC);
 		usb_submit_urb(entry->urb, GFP_ATOMIC);
=20
 		rt2x00_ring_index_inc(ring);
@@ -808,6 +813,9 @@ rt2500usb_txdone(void *data)
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D rt2x00usb_txdesc_addr(entry);
=20
+		if (GET_FLAG(entry, ENTRY_OWNER_NIC))
+			break;
+
 		ack =3D rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 =09
 		/*
@@ -861,6 +869,9 @@ rt2500usb_interrupt(struct urb *urb, str
 	struct rt2x00_usb	*rt2x00usb =3D
 		ieee80211_dev_hw_data(entry->ring->net_dev);
=20
+	if (!GET_FLAG(rt2x00usb, RADIO_ENABLED))
+		return;
+
 	if (urb->status)
 		return;
=20
@@ -989,7 +1000,7 @@ rt2500usb_allocate_rings(struct rt2x00_u
 		return -ENOMEM;
 	}
=20
=2D	rt2x00usb->atim_available =3D 1;
+	SET_FLAG(rt2x00usb, ATIM_AVAILABLE);
=20
 	if (rt2500usb_alloc_ring(
 		rt2x00usb, &rt2x00usb->ring[RING_RX], &rt2500usb_rxdone,
@@ -1049,6 +1060,7 @@ rt2500usb_init_rxring(struct rt2x00_usb=20
 			ring->entry_size + ring->desc_size,
 			rt2500usb_interrupt,
 			&entry[counter]);
+		SET_FLAG(&entry[counter], ENTRY_OWNER_NIC | ENTRY_TYPE_RX);
 		usb_submit_urb(entry[counter].urb, GFP_ATOMIC);
 	}
 }
@@ -1063,6 +1075,7 @@ rt2500usb_init_txring(struct rt2x00_usb=20
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
 		entry[counter].urb->transfer_dma =3D entry[counter].data_dma;
+		CLEAR_FLAGS(&entry[counter]);
 	}
 }
=20
@@ -1223,6 +1236,8 @@ rt2500usb_tx(struct net_device *net_dev,
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
+	struct usb_devive	*usb_dev =3D
+		interface_to_usbdev(rt2x00usb->usb_intf);
 	struct data_ring	*ring;
 	struct data_entry	*entry;
 	struct txd		*txd;
@@ -1247,6 +1262,7 @@ rt2500usb_tx(struct net_device *net_dev,
 	rt2500usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb =3D skb;
=20
+	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
 		entry->urb,
 		usb_dev,
@@ -1320,6 +1336,8 @@ rt2500usb_open(struct net_device *net_de
 	rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00usb, TXRX_CSR2, reg);
=20
+	SET_FLAG(rt2x00usb, RADIO_ENABLED);
+
 	return 0;
=20
 exit_fail:
@@ -1336,6 +1354,8 @@ rt2500usb_stop(struct net_device *net_de
 	int			counter;
 	u16			reg;
=20
+	CLEAR_FLAG(rt2x00usb, RADIO_ENABLED);
+
 	/*
 	 * Cancel RX.
 	 */
@@ -1609,6 +1629,8 @@ rt2500usb_beacon_update(struct net_devic
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
+	struct usb_devive	*usb_dev =3D
+		interface_to_usbdev(rt2x00usb->usb_intf);
 	struct data_entry	*entry;
=20
 	entry =3D rt2x00_get_data_entry(&rt2x00usb->ring[RING_BEACON]);
@@ -1624,6 +1646,7 @@ rt2500usb_beacon_update(struct net_devic
 	rt2500usb_write_tx_desc(rt2x00usb,
 		rt2x00usb_txdesc_addr(entry), skb, control);
=20
+	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
 		entry->urb,
 		usb_dev,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:55:14.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:56:05.000000000 +0200
@@ -648,6 +648,13 @@ struct rxd{
  */
 struct data_entry{
 	/*
+	 * Status flag.
+	 */
+	unsigned int			flags;
+#define ENTRY_OWNER_NIC			0x00000001
+#define ENTRY_TYPE_RX			0x00000002
+
+	/*
 	 * Ring we belong to.
 	 */
 	struct data_ring		*ring;
@@ -717,6 +724,11 @@ rt2x00usb_txdesc_addr(struct data_entry=20
  */
 struct rt2x00_usb{
 	/*
+	 * Device flags.
+	 */
+	unsigned int				flags;
+
+	/*
 	 * PCI device structure.
 	 */
 	struct usb_interface			*usb_intf;
@@ -748,8 +760,6 @@ struct rt2x00_usb{
 	 */
 	struct ieee80211_rx_status		rx_params;
=20
=2D	u8					atim_available;
=2D
 	/*
 	 * Alignment.
 	 */
@@ -798,7 +808,7 @@ rt2x00usb_get_ring(struct rt2x00_usb *rt
 {
 	u8					atim;
=20
=2D	atim =3D rt2x00usb->atim_available;
+	atim =3D GET_FLAG(rt2x00usb, ATIM_AVAILABLE);
=20
 	/*
 	 * Check if the rings have been allocated.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:52:01.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:56:05.000000000 +0200
@@ -93,6 +93,32 @@ static int rt2x00_debug_level =3D 0;
 #define BEACON_ENTRIES			1
=20
 /*
+ * Flag handlers
+ */
+#define SET_FLAG(__dev, __flag)		( (__dev)->flags |=3D (__flag) )
+#define GET_FLAG(__dev, __flag)		( !!((__dev)->flags & (__flag)) )
+#define CLEAR_FLAG(__dev, __flag)	( (__dev)->flags &=3D ~(__flag) )
+#define CLEAR_FLAGS(__dev)		( (__dev)->flags =3D 0 )
+
+/*
+ * Device flags
+ */
+#define INTERFACE_INITIALIZED			0x00000001
+#define INTERFACE_PROMISC			0x00000002
+#define FIRMWARE_FAILED				0x00000004
+#define FIRMWARE_LOADED				0x00000008
+#define RADIO_ENABLED				0x00000010
+#define RADIO_RESUME				0x00000020
+#define ATIM_AVAILABLE				0x00000040
+#define FRAME_TYPE				0x00000080
+#define EXTERNAL_LNA				0x00000100
+#define EXTERNAL_LNA_A				0x00000200
+#define EXTERNAL_LNA_BG				0x00000400
+#define RF_SEQUENCE				0x00000800
+#define DOUBLE_ANTENNA				0x00001000
+#define HARDWARE_BUTTON				0x00002000
+
+/*
  * TX result flags.
  */
 enum TX_STATUS {

--nextPart4027525.EqVVj7vATB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+kaqndE37Em0gRAuAZAJ90BW82JSNevwtSaytXpN6P/qzhrQCgt272
c7Ljc3q2bztboha1udaCLRk=
=qdAC
-----END PGP SIGNATURE-----

--nextPart4027525.EqVVj7vATB--
