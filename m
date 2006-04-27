From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 6/32] rt2x00: Use arraylike accessors for entries in DMA ring
Date: Fri, 28 Apr 2006 00:02:56 +0200
Message-ID: <200604280002.56857.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1982021.BVDVOePir1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751779AbWD0WBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:49 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:48 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1982021.BVDVOePir1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Make the code a bit more readable by using
array like accessors for pointers in a loop.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:39:24.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:40:06.000000000 +0200
@@ -951,15 +951,15 @@ rt2400pci_alloc_ring(
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		entry->skb =3D NULL;
=2D		entry->desc_addr =3D ring->data_addr
+		entry[counter].skb =3D NULL;
+		entry[counter].desc_addr =3D ring->data_addr
 			+ (counter * ring->desc_size);
=2D		entry->data_addr =3D ring->data_addr
+		entry[counter].data_addr =3D ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
=2D		entry->data_dma =3D ring->data_dma
+		entry[counter].data_dma =3D ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
 	}
@@ -989,14 +989,14 @@ rt2400pci_init_rxdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		rxd =3D entry->desc_addr;
+		rxd =3D entry[counter].desc_addr;
=20
 		rt2x00_set_field32(&rxd->word2, RXD_W2_BUFFER_LENGTH,
 			ring->data_size);
 		rt2x00_set_field32(&rxd->word1, RXD_W1_BUFFER_ADDRESS,
=2D			entry->data_dma);
+			entry[counter].data_dma);
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
 	}
=20
@@ -1012,14 +1012,14 @@ rt2400pci_init_txdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		txd =3D entry->desc_addr;
+		txd =3D entry[counter].desc_addr;
=20
 		rt2x00_set_field32(&txd->word2, TXD_W2_BUFFER_LENGTH,
 			ring->data_size);
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_ADDRESS,
=2D			entry->data_dma);
+			entry[counter].data_dma);
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		rt2x00_set_field32(&txd->word0, TXD_W0_OWNER_NIC, 0);
 	}
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:39:24.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:40:06.000000000 +0200
@@ -987,15 +987,15 @@ rt2500pci_alloc_ring(
 	 * Initialize all ring entries to contain valid
 	 * addresses.
 	 */
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		entry->skb =3D NULL;
=2D		entry->desc_addr =3D ring->data_addr
+		entry[counter].skb =3D NULL;
+		entry[counter].desc_addr =3D ring->data_addr
 			+ (counter * ring->desc_size);
=2D		entry->data_addr =3D ring->data_addr
+		entry[counter].data_addr =3D ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
=2D		entry->data_dma =3D ring->data_dma
+		entry[counter].data_dma =3D ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
 	}
@@ -1025,12 +1025,12 @@ rt2500pci_init_rxdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		rxd =3D entry->desc_addr;
+		rxd =3D entry[counter].desc_addr;
=20
 		rt2x00_set_field32(&rxd->word1, RXD_W1_BUFFER_ADDRESS,
=2D			entry->data_dma);
+			entry[counter].data_dma);
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
 	}
=20
@@ -1046,12 +1046,12 @@ rt2500pci_init_txdesc(struct rt2x00_pci=20
=20
 	memset(ring->data_addr, 0x00, rt2x00_get_ring_size(ring));
=20
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		txd =3D entry->desc_addr;
+		txd =3D entry[counter].desc_addr;
=20
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_ADDRESS,
=2D			entry->data_dma);
+			entry[counter].data_dma);
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		rt2x00_set_field32(&txd->word0, TXD_W0_OWNER_NIC, 0);
 	}
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:39:24.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:40:06.000000000 +0200
@@ -803,22 +803,22 @@ rt2500usb_alloc_ring(
 	 * addresses.
 	 */
 	status =3D 0;
+	entry =3D (struct data_entry*)ring->entry;
 	for (counter =3D 0; counter < ring->stats.limit; counter++) {
=2D		entry =3D ring->entry + (counter * ring->entry_size);
=2D		entry->ring =3D ring;
+		entry[counter].ring =3D ring;
 		if (!status)
=2D			entry->urb =3D usb_alloc_urb(0, GFP_KERNEL);
+			entry[counter].urb =3D usb_alloc_urb(0, GFP_KERNEL);
 		else
=2D			entry->urb =3D NULL;
=2D		if (entry->urb =3D=3D NULL)
+			entry[counter].urb =3D NULL;
+		if (entry[counter].urb =3D=3D NULL)
 			status =3D -ENOMEM;
=2D		entry->skb =3D NULL;
=2D		entry->desc_addr =3D ring->data_addr
+		entry[counter].skb =3D NULL;
+		entry[counter].desc_addr =3D ring->data_addr
 			+ (counter * ring->desc_size);
=2D		entry->data_addr =3D ring->data_addr
+		entry[counter].data_addr =3D ring->data_addr
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
=2D		entry->data_dma =3D ring->data_dma
+		entry[counter].data_dma =3D ring->data_dma
 			+ (ring->stats.limit * ring->desc_size)
 			+ (counter * ring->data_size);
 	}

--nextPart1982021.BVDVOePir1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+QaqndE37Em0gRAvgzAKC0snJG/fD7NPI88sHhcB81zkHE5wCgmC5d
l/G/a14dcQT37vpTRzydOo8=
=FqaR
-----END PGP SIGNATURE-----

--nextPart1982021.BVDVOePir1--
