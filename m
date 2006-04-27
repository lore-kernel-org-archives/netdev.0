From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 23/32] rt2x00: Make correct cast in USB interrupt
Date: Fri, 28 Apr 2006 00:03:14 +0200
Message-ID: <200604280003.15151.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2045314.hlAv00zd7U";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.184]:37997 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751789AbWD0WCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:15 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463914nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:14 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2045314.hlAv00zd7U
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

The USB interrupt handler receives the entry
in the ring and not the ring itself.
Also check if the status indicates an error
before queueing the work.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:54:33.000000000 +0200
@@ -856,11 +856,14 @@ rt2500usb_txdone(void *data)
 static void
 rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)urb->context;
+	struct data_entry	*entry =3D (struct data_entry*)urb->context;
 	struct rt2x00_usb	*rt2x00usb =3D
=2D		ieee80211_dev_hw_data(ring->net_dev);
+		ieee80211_dev_hw_data(entry->ring->net_dev);
=20
=2D	queue_work(rt2x00usb->workqueue, &ring->irq_work);
+	if (urb->status)
+		return;
+
+	queue_work(rt2x00usb->workqueue, &entry->ring->irq_work);
 }
=20
 /*
@@ -1064,7 +1067,6 @@ rt2500usb_init_txring(struct rt2x00_usb=20
 	}
 }
=20
=2D
 static int
 rt2500usb_init_rings(struct rt2x00_usb *rt2x00usb)
 {
@@ -1798,7 +1800,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D vals[counter] | rf2_base;
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2525E)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x0000089a, 0x0000089e, 0x0000089e, 0x000008a2,
 			0x000008a2, 0x000008a6, 0x000008a6, 0x000008aa,
 			0x000008aa, 0x000008ae, 0x000008ae, 0x000008b2,

--nextPart2045314.hlAv00zd7U
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+jaqndE37Em0gRAjCbAKC8ikJRAtU0YfY8oNCQiGGxlbPA0QCfVkA4
oDEExf7HFCH3R6vmGn1aUww=
=5Lph
-----END PGP SIGNATURE-----

--nextPart2045314.hlAv00zd7U--
