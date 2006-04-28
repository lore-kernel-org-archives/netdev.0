From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/6] rt2x00 update: Remove casts from void* pointers
Date: Fri, 28 Apr 2006 16:52:25 +0200
Message-ID: <200604281652.26343.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1373691.BF4NE5AFta";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.186]:2272 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S965214AbWD1Ov0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:26 -0400
Received: by nproxy.gmail.com with SMTP id x30so1507175nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:24 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1373691.BF4NE5AFta
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Remove unneeded casts when working with a void* pointer.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-28 15:09:53.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-28 15:13:49.000000000 +0200
@@ -917,7 +917,7 @@ rt2400pci_write_tx_desc(
 static void
 rt2400pci_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct sk_buff		*skb;
@@ -938,7 +938,7 @@ rt2400pci_beacondone(void *data)
 static void
 rt2400pci_rxdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -995,7 +995,7 @@ rt2400pci_rxdone(void *data)
 static void
 rt2400pci_txdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -1067,7 +1067,7 @@ rt2400pci_txdone(void *data)
 static irqreturn_t
 rt2400pci_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
 {
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)dev_instance;
+	struct rt2x00_pci	*rt2x00pci =3D dev_instance;
 	u32			reg;
=20
 	/*
@@ -1187,7 +1187,7 @@ rt2400pci_alloc_ring(
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].skb =3D NULL;
 		entry[counter].desc_addr =3D ring->data_addr
@@ -1275,7 +1275,7 @@ rt2400pci_init_rxdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		rxd =3D entry[counter].desc_addr;
=20
@@ -1298,7 +1298,7 @@ rt2400pci_init_txdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		txd =3D entry[counter].desc_addr;
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-28 15:09:53.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-28 15:12:23.000000000 +0200
@@ -994,7 +994,7 @@ rt2500pci_write_tx_desc(
 static void
 rt2500pci_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct sk_buff		*skb;
@@ -1015,7 +1015,7 @@ rt2500pci_beacondone(void *data)
 static void
 rt2500pci_rxdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -1083,7 +1083,7 @@ rt2500pci_rxdone(void *data)
 static void
 rt2500pci_txdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_pci	*rt2x00pci =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -1155,7 +1155,7 @@ rt2500pci_txdone(void *data)
 static irqreturn_t
 rt2500pci_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
 {
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)dev_instance;
+	struct rt2x00_pci	*rt2x00pci =3D dev_instance;
 	u32			reg;
=20
 	/*
@@ -1276,7 +1276,7 @@ rt2500pci_alloc_ring(
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].skb =3D NULL;
 		entry[counter].desc_addr =3D ring->data_addr
@@ -1364,7 +1364,7 @@ rt2500pci_init_rxdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		rxd =3D entry[counter].desc_addr;
=20
@@ -1385,7 +1385,7 @@ rt2500pci_init_txdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		txd =3D entry[counter].desc_addr;
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-28 15:09:53.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-28 15:13:01.000000000 +0200
@@ -818,7 +818,7 @@ rt2500usb_write_tx_desc(
 static void
 rt2500usb_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_usb	*rt2x00usb =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct sk_buff		*skb;
@@ -839,7 +839,7 @@ rt2500usb_beacondone(void *data)
 static void
 rt2500usb_rxdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_usb	*rt2x00usb =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -924,7 +924,7 @@ rt2500usb_rxdone(void *data)
 static void
 rt2500usb_txdone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
+	struct data_ring	*ring =3D data;
 	struct rt2x00_usb	*rt2x00usb =3D
 		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
@@ -1069,7 +1069,7 @@ rt2500usb_alloc_ring(
 	 * addresses.
 	 */
 	status =3D 0;
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].ring =3D ring;
 		if (!status)
@@ -1099,7 +1099,7 @@ rt2500usb_free_ring(struct rt2x00_usb *r
 	if (!ring->entry)
 		goto exit;
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		usb_kill_urb(entry[counter].urb);
 		usb_free_urb(entry[counter].urb);
@@ -1175,7 +1175,7 @@ rt2500usb_init_rxring(struct rt2x00_usb=20
 	struct data_entry	*entry;
 	u8			counter;
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
 		entry[counter].urb->transfer_dma =3D entry[counter].data_dma;
@@ -1198,7 +1198,7 @@ rt2500usb_init_txring(struct rt2x00_usb=20
 	struct data_entry	*entry;
 	u8			counter;
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
 		entry[counter].urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
 		entry[counter].urb->transfer_dma =3D entry[counter].data_dma;
@@ -1410,7 +1410,7 @@ rt2500usb_reset_ring(struct data_ring *r
 	struct data_entry	*entry;
 	int			counter;
=20
=2D	entry =3D (struct data_entry*)ring->entry;
+	entry =3D ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++)
 		usb_kill_urb(entry[counter].urb);
 }

--nextPart1373691.BF4NE5AFta
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwqaqndE37Em0gRAjMMAJ0UmEdCDYNYOb9sOFDDvgxA4EqsvACgpshR
UelXqLVSvddP+HHd6h/5HhI=
=0/LY
-----END PGP SIGNATURE-----

--nextPart1373691.BF4NE5AFta--
