From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] set freq in ieee80211_rx_status
Date: Thu, 19 Oct 2006 02:13:47 -0400
Message-ID: <200610190213.52509.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1744551.Zt6fJEvyrp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: developers@islsm.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:1312 "EHLO annwn13.rutgers.edu")
	by vger.kernel.org with ESMTP id S1161324AbWJSGPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 02:15:03 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1744551.Zt6fJEvyrp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

set freq in ieee80211_rx_status

This patch fixes the RX handler in adm8211 and p54 to report the current=20
frequency and channel. Should probably be handled in d80211 instead, but th=
is=20
will fix things for now. It also eliminates some definitions in adm8211.h=20
that are no longer necessary.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c   |    3 ++
 drivers/net/wireless/d80211/adm8211/adm8211.h   |   42=20
++++++++---------------
 drivers/net/wireless/d80211/p54/prism54.h       |    1 +
 drivers/net/wireless/d80211/p54/prism54common.c |    6 +++
 4 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 3bce55f..9f965d3 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -551,6 +551,9 @@ static void adm8211_interrupt_rci(struct
 			if (rate <=3D 4)
 				rx_status.rate =3D rate_tbl[rate];
=20
+			rx_status.channel =3D priv->channel;
+			rx_status.freq =3D adm8211_channels[priv->channel - 1].freq;
+
 			/* remove FCS */
 			/* TODO: remove this and set flag in ieee80211_hw instead? */
 			if (dev->flags & IFF_PROMISC)
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.h=20
b/drivers/net/wireless/d80211/adm8211/adm8211.h
index 89e0fdf..a579a90 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.h
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.h
@@ -590,47 +590,33 @@ static const struct ieee80211_chan_range
=20
 static const struct ieee80211_channel adm8211_channels[] =3D {
 	{ .chan =3D 1,
=2D	  .freq =3D 2412,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2412},
 	{ .chan =3D 2,
=2D	  .freq =3D 2417,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2417},
 	{ .chan =3D 3,
=2D	  .freq =3D 2422,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2422},
 	{ .chan =3D 4,
=2D	  .freq =3D 2427,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2427},
 	{ .chan =3D 5,
=2D	  .freq =3D 2432,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2432},
 	{ .chan =3D 6,
=2D	  .freq =3D 2437,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2437},
 	{ .chan =3D 7,
=2D	  .freq =3D 2442,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2442},
 	{ .chan =3D 8,
=2D	  .freq =3D 2447,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2447},
 	{ .chan =3D 9,
=2D	  .freq =3D 2452,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2452},
 	{ .chan =3D 10,
=2D	  .freq =3D 2457,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2457},
 	{ .chan =3D 11,
=2D	  .freq =3D 2462,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2462},
 	{ .chan =3D 12,
=2D	  .freq =3D 2467,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2467},
 	{ .chan =3D 13,
=2D	  .freq =3D 2472,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS},
+	  .freq =3D 2472},
 	{ .chan =3D 14,
=2D	  .freq =3D 2484,
=2D	  .flag =3D IEEE80211_CHAN_W_SCAN | IEEE80211_CHAN_W_ACTIVE_SCAN |=20
IEEE80211_CHAN_W_IBSS}
+	  .freq =3D 2484},
 };
=20
 #endif /* ADM8211_H */
diff --git a/drivers/net/wireless/d80211/p54/prism54.h=20
b/drivers/net/wireless/d80211/p54/prism54.h
index a165cc5..f2aaafe 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54.h
+++ b/drivers/net/wireless/d80211/p54/prism54.h
@@ -53,6 +53,7 @@ struct p54_common {
 	int (*open)(struct net_device *dev);
 	void (*stop)(struct net_device *dev);
 	int mode;
+	int channel;
 	struct pda_iq_autocal_entry *iq_autocal;
 	unsigned int iq_autocal_len;
 	struct pda_channel_output_limit *output_limit;
diff --git a/drivers/net/wireless/d80211/p54/prism54common.c=20
b/drivers/net/wireless/d80211/p54/prism54common.c
index a96a4fc..34bccee 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -206,11 +206,14 @@ EXPORT_SYMBOL_GPL(p54_parse_eeprom);
=20
 static void p54_rx_data(struct net_device *dev, struct sk_buff *skb)
 {
+	struct p54_common *priv =3D ieee80211_dev_hw_data(skb->dev);
 	struct p54_rx_hdr *hdr =3D (struct p54_rx_hdr *) skb->data;
 	struct ieee80211_rx_status rx_status =3D {0};
=20
 	rx_status.ssi =3D hdr->rssi;	/* TODO: check this */
 	rx_status.rate =3D min(hdr->rate + 1, 12);	/* TODO: check this */
+	rx_status.channel =3D priv->channel;
+	rx_status.freq =3D p54_channels[priv->channel - 1].freq;
=20
 	skb_pull(skb, sizeof(*hdr));
 	skb_trim(skb, le16_to_cpu(hdr->len));
@@ -579,6 +582,8 @@ static void p54_remove_interface(struct=20
=20
 static int p54_config(struct net_device *dev, struct ieee80211_conf *conf)
 {
+	struct p54_common *priv =3D ieee80211_dev_hw_data(dev);
+	priv->channel =3D conf->channel;
 	p54_set_freq(dev, cpu_to_le16(conf->freq));
 	return 0;
 }
@@ -611,6 +616,7 @@ void p54_init_common(struct net_device *
 	struct ieee80211_hw *hw =3D &priv->hw;
=20
 	priv->mode =3D IEEE80211_IF_TYPE_MGMT;
+	priv->channel =3D 1;
 	skb_queue_head_init(&priv->tx_queue);
 	memcpy(priv->channels, p54_channels, sizeof(p54_channels));
 	memcpy(priv->rates, p54_rates, sizeof(p54_rates));

--nextPart1744551.Zt6fJEvyrp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFNxegT3Oqt9AH4aERAuhBAKCc8c4K6OBDDSY4FfWGw5qLYMD1xwCgnHaY
ltF7LW/RiI9i8sKEJ67O6d8=
=ykwC
-----END PGP SIGNATURE-----

--nextPart1744551.Zt6fJEvyrp--
