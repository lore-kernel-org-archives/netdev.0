From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 6/6] rt2x00 update: Apply correct error handling to dscape stack
Date: Fri, 28 Apr 2006 16:52:29 +0200
Message-ID: <200604281652.29811.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2754635.t0TSqM92Ui";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:26336 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030413AbWD1Ov2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:51:28 -0400
Received: by nproxy.gmail.com with SMTP id n29so1594535nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 07:51:28 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2754635.t0TSqM92Ui
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Return correct error code at failure, and
request debug report when the function _tx()
has received an invalid queue.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-28 15:32:12.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-28 16:34:55.000000000 +0200
@@ -1538,20 +1538,21 @@ rt2400pci_tx(struct net_device *net_dev,
 	 */
 	ring =3D rt2x00pci_get_ring(rt2x00pci, control->queue);
 	if (unlikely(!ring)) {
=2D		ERROR("Attempt to send packet over invalid queue %d.\n",
=2D			control->queue);
=2D		return NET_RX_DROP;
+		ERROR("Attempt to send packet over invalid queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		return NET_XMIT_DROP;
 	}
=20
 	if (rt2x00_ring_full(ring))
=2D		return NET_RX_DROP;
+		return NET_XMIT_DROP;
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D entry->desc_addr;
=20
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
 	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
=2D		return NET_RX_DROP;
+		return NET_XMIT_DROP;
=20
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -2032,7 +2033,7 @@ rt2400pci_conf_tx(struct net_device *net
 	 */
 	if (queue !=3D IEEE80211_TX_QUEUE_DATA0) {
 		NOTICE("Ignoring configuration for queue %d.\n", queue);
=2D		return 0;
+		return -EINVAL;
 	}
=20
 	memcpy(&ring->tx_params, params, sizeof(*params));
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-28 15:32:31.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-28 16:34:54.000000000 +0200
@@ -1661,20 +1661,21 @@ rt2500pci_tx(struct net_device *net_dev,
 	 */
 	ring =3D rt2x00pci_get_ring(rt2x00pci, control->queue);
 	if (unlikely(!ring)) {
=2D		ERROR("Attempt to send packet over invalid queue %d.\n",
=2D			control->queue);
=2D		return NET_RX_DROP;
+		ERROR("Attempt to send packet over invalid queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		return NET_XMIT_DROP;
 	}
=20
 	if (rt2x00_ring_full(ring))
=2D		return NET_RX_DROP;
+		return NET_XMIT_DROP;
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D entry->desc_addr;
=20
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
 	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
=2D		return NET_RX_DROP;
+		return NET_XMIT_DROP;
=20
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -2147,7 +2148,7 @@ rt2500pci_conf_tx(struct net_device *net
 	ring =3D rt2x00pci_get_ring(rt2x00pci, queue);
 	if (unlikely(!ring)) {
 		NOTICE("Ignoring configuration for queue %d.\n", queue);
=2D		return 0;
+		return -EINVAL;
 	}
=20
 	memcpy(&ring->tx_params, params, sizeof(*params));
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-28 15:32:06.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-28 16:34:56.000000000 +0200
@@ -1373,13 +1373,14 @@ rt2500usb_tx(struct net_device *net_dev,
 	 */
 	ring =3D rt2x00usb_get_ring(rt2x00usb, control->queue);
 	if (unlikely(!ring)) {
=2D		ERROR("Attempt to send packet over invalid queue %d.\n",
=2D			control->queue);
=2D		return NET_RX_DROP;
+		ERROR("Attempt to send packet over invalid queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		return NET_XMIT_DROP;
 	}
=20
 	if (rt2x00_ring_full(ring))
=2D		return NET_RX_DROP;
+		return NET_XMIT_DROP;
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D rt2x00usb_txdesc_addr(entry);
@@ -1797,7 +1798,7 @@ rt2500usb_conf_tx(struct net_device *net
 	ring =3D rt2x00usb_get_ring(rt2x00usb, queue);
 	if (unlikely(!ring)) {
 		NOTICE("Ignoring configuration for queue %d.\n", queue);
=2D		return 0;
+		return -EINVAL;
 	}
=20
 	memcpy(&ring->tx_params, params, sizeof(*params));

--nextPart2754635.t0TSqM92Ui
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUiwtaqndE37Em0gRAts1AJwOEQuIMnCA+qQIDfDfVUlT1WXdFACgl6Lb
NPDyNTBlea6i1hM8qroJB0w=
=9jdN
-----END PGP SIGNATURE-----

--nextPart2754635.t0TSqM92Ui--
