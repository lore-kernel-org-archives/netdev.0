From: Michael Wu <flamingice@sourmilk.net>
Subject: Fixes for d80211 hwmode API change
Date: Thu, 4 Jan 2007 13:05:58 -0500
Message-ID: <200701041306.08603.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2538081.9dURNhhJ0j";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:36304 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217AbXADSGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 13:06:41 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2538081.9dURNhhJ0j
Content-Type: multipart/mixed;
  boundary="Boundary-01=_GIUnFWk3Hozt2r8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_GIUnFWk3Hozt2r8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

These attached patches are a simplified version of Michael Buesch's origina=
l=20
hwmode API patches to adm8211, p54, and zd1211rw-d80211. These will be=20
necessary once you pull up2 from Jiri Benc's tree.

Thanks,
=2DMichael Wu

--Boundary-01=_GIUnFWk3Hozt2r8
Content-Type: text/x-diff;
  charset="us-ascii";
  name="adm8211-hwmode"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="adm8211-hwmode"

adm8211: Fix compilation for d80211 hwmode API change

=46rom: Michael Wu <flamingice@sourmilk.net>

This fixes compilation for the d80211 hwmode API change.

Based on a patch by Michael Buesch <mb@bu3sch.de>.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |    8 ++++++--
 drivers/net/wireless/d80211/adm8211/adm8211.h |    2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wi=
reless/d80211/adm8211/adm8211.c
index d7fb484..3bdcec3 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2035,8 +2035,6 @@ static int __devinit adm8211_probe(struc
 	dev->channel_change_time =3D 1000;
 	dev->maxssi =3D ADM8211_RX_MAX_SSI;// FIXME - This is an approximation
=20
=2D	dev->num_modes =3D 1;
=2D	dev->modes =3D priv->modes;
 	priv->modes[0].mode =3D MODE_IEEE80211B;
 	/* channel info filled in by adm8211_read_eeprom */
 	memcpy(priv->rates, adm8211_rates, sizeof(adm8211_rates));
@@ -2069,6 +2067,12 @@ static int __devinit adm8211_probe(struc
=20
 	priv->channel =3D priv->modes[0].channels[0].chan;
=20
+	err =3D ieee80211_register_hwmode(dev, &priv->modes[0]);
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot register hwmode\n", pci_name(pdev)=
);
+		goto err_free_desc;
+	}
+
 	err =3D ieee80211_register_hw(dev);
 	if (err) {
 		printk(KERN_ERR "%s (adm8211): Cannot register hardware\n", pci_name(pde=
v));
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.h b/drivers/net/wi=
reless/d80211/adm8211/adm8211.h
index 06c54bc..dc7902f 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.h
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.h
@@ -532,7 +532,7 @@ struct adm8211_priv {
 	unsigned cur_tx, dirty_tx, cur_rx;
=20
 	struct ieee80211_low_level_stats stats;
=2D	struct ieee80211_hw_modes modes[1];
+	struct ieee80211_hw_mode modes[1];
 	struct ieee80211_rate rates[ARRAY_SIZE(adm8211_rates)];
 	int mode;
=20

--Boundary-01=_GIUnFWk3Hozt2r8
Content-Type: text/x-diff;
  charset="us-ascii";
  name="p54-hwmode"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="p54-hwmode"

p54: Fix compilation for d80211 hwmode API change

=46rom: Michael Wu <flamingice@sourmilk.net>

This fixes compilation for the d80211 hwmode API change.

Based on a patch by Michael Buesch <mb@bu3sch.de>.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/p54/prism54.h       |    2 +-
 drivers/net/wireless/d80211/p54/prism54common.c |   11 ++++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/d80211/p54/prism54.h b/drivers/net/wirele=
ss/d80211/p54/prism54.h
index 5e4f331..de8197e 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54.h
+++ b/drivers/net/wireless/d80211/p54/prism54.h
@@ -63,7 +63,7 @@ struct p54_common {
 	/* FIXME: this channels/modes/rates stuff sucks */
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
=2D	struct ieee80211_hw_modes modes[2];
+	struct ieee80211_hw_mode modes[2];
 };
=20
 int p54_rx(struct ieee80211_hw *dev, struct sk_buff *skb);
diff --git a/drivers/net/wireless/d80211/p54/prism54common.c b/drivers/net/=
wireless/d80211/p54/prism54common.c
index 185cd53..2e19bf4 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -745,6 +745,7 @@ struct ieee80211_hw *p54_init_common(siz
 {
 	struct ieee80211_hw *dev;
 	struct p54_common *priv;
+	int i;
=20
 	dev =3D ieee80211_alloc_hw(priv_data_len, &p54_ops);
 	if (!dev)
@@ -774,13 +775,17 @@ struct ieee80211_hw *p54_init_common(siz
 	dev->channel_change_time =3D 1000;	/* TODO: find actual value */
 	dev->maxssi =3D 100; // just to avoid dividing by zero
=20
=2D	dev->num_modes =3D 2;
=2D	dev->modes =3D priv->modes;
=2D
 	dev->queues =3D 1;
 	dev->extra_tx_headroom =3D sizeof(struct p54_control_hdr) + 4 +
 				 sizeof(struct p54_tx_control_allocdata);
=20
+	for (i =3D 0; i < 2; i++) {
+		if (ieee80211_register_hwmode(dev, &priv->modes[i])) {
+			ieee80211_free_hw(dev);
+			return NULL;
+		}
+	}=09
+
 	return dev;
 }
 EXPORT_SYMBOL_GPL(p54_init_common);

--Boundary-01=_GIUnFWk3Hozt2r8
Content-Type: text/x-diff;
  charset="us-ascii";
  name="zd1211rw-hwmode"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="zd1211rw-hwmode"

zd1211rw-d80211: Fix compilation for d80211 hwmode API change

=46rom: Michael Wu <flamingice@sourmilk.net>

This fixes compilation for the d80211 hwmode API change.

Based on a patch by Michael Buesch <mb@bu3sch.de>.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/zd1211rw/zd_mac.c |   12 +++++++++---
 drivers/net/wireless/d80211/zd1211rw/zd_mac.h |    2 +-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.c
index 6ee650f..35c90fb 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
@@ -574,6 +574,7 @@ struct ieee80211_hw *zd_mac_alloc(struct
 {
 	struct zd_mac *mac;
 	struct ieee80211_hw *dev;
+	int i;
=20
 	dev =3D ieee80211_alloc_hw(sizeof(struct zd_mac), &zd_ops);
 	if (!dev) {
@@ -608,12 +609,17 @@ struct ieee80211_hw *zd_mac_alloc(struct
 		     IEEE80211_HW_WEP_INCLUDE_IV;
 	dev->maxssi =3D 100;
=20
=2D	dev->num_modes =3D 2;
=2D	dev->modes =3D mac->modes;
=2D
 	dev->queues =3D 1;
 	dev->extra_tx_headroom =3D sizeof(struct zd_ctrlset);
=20
+	for (i =3D 0; i < 2; i++) {
+		if (ieee80211_register_hwmode(dev, &mac->modes[i])) {
+			dev_dbg_f(&intf->dev, "cannot register hwmode\n");
+			ieee80211_free_hw(dev);
+			return NULL;
+		}
+	}
+
 	skb_queue_head_init(&mac->tx_queue);
 	zd_chip_init(&mac->chip, dev, intf);
 	housekeeping_init(mac);
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.h
index e2ba410..492f7f5 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
@@ -138,7 +138,7 @@ struct zd_mac {
 	struct sk_buff_head tx_queue;
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
=2D	struct ieee80211_hw_modes modes[2];
+	struct ieee80211_hw_mode modes[2];
 };
=20
 static inline struct zd_mac *zd_dev_mac(struct ieee80211_hw *dev)

--Boundary-01=_GIUnFWk3Hozt2r8--

--nextPart2538081.9dURNhhJ0j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFnUIQT3Oqt9AH4aERAo+yAKCYZqhJVSztJkGUSutIpCnlLHuMtQCfT3uG
VXUJ2Bj2RKBlYNPp5g94Gz8=
=KfvI
-----END PGP SIGNATURE-----

--nextPart2538081.9dURNhhJ0j--
