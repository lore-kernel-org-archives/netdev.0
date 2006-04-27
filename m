From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 7/32] rt2x00: make vals static
Date: Fri, 28 Apr 2006 00:02:57 +0200
Message-ID: <200604280002.58147.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2702740.5Afo1gLNcc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751782AbWD0WBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:50 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:49 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2702740.5Afo1gLNcc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

The vals[] arrays in *_init_hw_channels can be made
static to optimize memory and reduce stack size.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:40:06.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:40:43.000000000 +0200
@@ -1868,7 +1868,7 @@ rt2400pci_init_hw_channels(struct rt2x00
 {
 	int				counter;
 	u16				eeprom;
=2D	u32 vals[] =3D {
+	static u32 vals[] =3D {
 		0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 		0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 		0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:40:06.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:40:43.000000000 +0200
@@ -1929,9 +1929,9 @@ rt2500pci_init_hw_channels(struct rt2x00
 	struct ieee80211_channel *channels)
 {
 	int				counter;
=2D	u16				eeprom;
 	u32				rf2_base;
=2D	struct {
+	u16				eeprom;
+	static struct {
 		unsigned int chip;
 		u32 val[3];
 	} rf[] =3D {
@@ -1947,16 +1947,16 @@ rt2500pci_init_hw_channels(struct rt2x00
 	 * Channel initialization.
 	 * First we set the basic variables.
 	 */
=2D		for (counter =3D 0; counter < 13; counter++) {
=2D			channels[counter].chan =3D counter + 1;
+	for (counter =3D 0; counter < 13; counter++) {
+		channels[counter].chan =3D counter + 1;
 		channels[counter].freq =3D 2407 + ((counter + 1) * 5);
 		channels[counter].flag =3D IEEE80211_CHAN_W_IBSS
 			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[counter].antenna_max =3D 0xff;
=2D		}
+	}
=20
=2D		channels[13].chan =3D 14;
=2D		channels[13].freq =3D 2484;
+	channels[13].chan =3D 14;
+	channels[13].freq =3D 2484;
 	channels[13].flag =3D IEEE80211_CHAN_W_IBSS
 		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max =3D 0xff;
@@ -1988,7 +1988,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 		rf2_base =3D 0x00080000;
=20
 	if (rt2x00_rf(&rt2x00pci->chip, RF2522)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 			0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 			0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
@@ -2000,7 +2000,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 	} else if (rt2x00_rf(&rt2x00pci->chip, RF2523)
 	|| rt2x00_rf(&rt2x00pci->chip, RF2524)
 	|| rt2x00_rf(&rt2x00pci->chip, RF2525)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x00000c9e, 0x00000ca2, 0x00000ca6, 0x00000caa,
 			0x00000cae, 0x00000cb2, 0x00000cb6, 0x00000cba,
 			0x00000cbe, 0x00000d02, 0x00000d06, 0x00000d0a,
@@ -2012,7 +2012,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 				cpu_to_le32(vals[counter] | rf2_base);
 	} else if (rt2x00_rf(&rt2x00pci->chip, RF2525E)
 	|| rt2x00_rf(&rt2x00pci->chip, RF5222)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x00001136, 0x0000113a, 0x0000113e, 0x00001182,
 			0x00001186, 0x0000118a, 0x0000118e, 0x00001192,
 			0x00001196, 0x0000119a, 0x0000119e, 0x000011a2,
@@ -2024,7 +2024,7 @@ rt2500pci_init_hw_channels(struct rt2x00
 				cpu_to_le32(vals[counter] | rf2_base);
 		}
 	if (rt2x00_rf(&rt2x00pci->chip, RF5222)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x00018896, 0x0001889a, 0x0001889e, 0x000188a2,
 			0x000188a6, 0x000188aa, 0x000188ae, 0x000188b2,
 			0x00008802, 0x00008806, 0x0000880a, 0x0000880e,
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:40:06.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:40:43.000000000 +0200
@@ -1629,9 +1629,9 @@ rt2500usb_init_hw_channels(struct rt2x00
 	struct ieee80211_channel *channels)
 {
 	int				counter;
=2D	u16				eeprom;
 	u32				rf2_base;
=2D	struct {
+	u16				eeprom;
+	static struct {
 		unsigned int chip;
 		u32 val[3];
 	} rf[] =3D {
@@ -1647,16 +1647,16 @@ rt2500usb_init_hw_channels(struct rt2x00
 	 * Channel initialization.
 	 * First we set the basic variables.
 	 */
=2D		for (counter =3D 0; counter < 13; counter++) {
=2D			channels[counter].chan =3D counter + 1;
+	for (counter =3D 0; counter < 13; counter++) {
+		channels[counter].chan =3D counter + 1;
 		channels[counter].freq =3D 2407 + ((counter + 1) * 5);
 		channels[counter].flag =3D IEEE80211_CHAN_W_IBSS
 			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[counter].antenna_max =3D 0xff;
=2D		}
+	}
=20
=2D		channels[13].chan =3D 14;
=2D		channels[13].freq =3D 2484;
+	channels[13].chan =3D 14;
+	channels[13].freq =3D 2484;
 	channels[13].flag =3D IEEE80211_CHAN_W_IBSS
 		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max =3D 0xff;
@@ -1687,7 +1687,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		rf2_base =3D 0x00080000;
=20
 	if (rt2x00_rf(&rt2x00usb->chip, RF2522)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x000c1fda, 0x000c1fee, 0x000c2002, 0x000c2016,
 			0x000c202a, 0x000c203e, 0x000c2052, 0x000c2066,
 			0x000c207a, 0x000c208e, 0x000c20a2, 0x000c20b6,
@@ -1699,7 +1699,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF2523)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2524)
 	|| rt2x00_rf(&rt2x00usb->chip, RF2525)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x00000c9e, 0x00000ca2, 0x00000ca6, 0x00000caa,
 			0x00000cae, 0x00000cb2, 0x00000cb6, 0x00000cba,
 			0x00000cbe, 0x00000d02, 0x00000d06, 0x00000d0a,
@@ -1720,7 +1720,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		for (counter =3D 0; counter < ARRAY_SIZE(vals); counter++)
 			channels[counter].val =3D cpu_to_le32(vals[counter]);
 	} else if (rt2x00_rf(&rt2x00usb->chip, RF5222)) {
=2D		u32 vals[] =3D {
+		static u32 vals[] =3D {
 			0x00001136, 0x0000113a, 0x0000113e, 0x00001182,
 			0x00001186, 0x0000118a, 0x0000118e, 0x00001192,
 			0x00001196, 0x0000119a, 0x0000119e, 0x000011a2,

--nextPart2702740.5Afo1gLNcc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+SaqndE37Em0gRAnHrAKDPxfctY2MnsmnZMeJnZAO3nk5qCQCg3yl1
Jy+YzNrAvAz9j9WSKK48ICc=
=kDnQ
-----END PGP SIGNATURE-----

--nextPart2702740.5Afo1gLNcc--
