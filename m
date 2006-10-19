From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] p54: fix stalling in TX queue
Date: Thu, 19 Oct 2006 02:22:38 -0400
Message-ID: <200610190222.43399.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2458614.4h5U19AnSe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: developers@islsm.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:64708 "EHLO
	annwn13.rutgers.edu") by vger.kernel.org with ESMTP
	id S1423257AbWJSGXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 02:23:48 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2458614.4h5U19AnSe
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

p54: fix stalling in TX queue

This patch makes the p54 TX queue not stall anymore. Probably not the most=
=20
efficient thing to do, but it's better than stalling.

It also adds a small comment to prism54common.h about the origin of the pda=
=20
definitions and inserts a missing verb in the comment for p54_assign_addres=
s.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/p54/prism54common.c |   10 +++++-----
 drivers/net/wireless/d80211/p54/prism54common.h |    2 ++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/d80211/p54/prism54common.c=20
b/drivers/net/wireless/d80211/p54/prism54common.c
index 34bccee..6f4cb5f 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -261,8 +261,8 @@ static void p54_rx_frame_sent(struct net
 		entry =3D entry->next;
 	}
 	=09
=2D	if (freed < IEEE80211_MAX_RTS_THRESHOLD + 0x170 + sizeof(struct=20
p54_control_hdr))
=2D		ieee80211_wake_queue(dev, 0);=09
+	if (skb_queue_empty(&priv->tx_queue))
+		ieee80211_wake_queue(dev, 0);
 }
=20
 static void p54_rx_control(struct net_device *dev, struct sk_buff *skb)
@@ -308,9 +308,9 @@ EXPORT_SYMBOL_GPL(p54_rx);
 /*
  * So, the firmware is somewhat stupid and doesn't know what places in its
  * memory incoming data should go to. By poking around in the firmware, we
=2D * can some unused memory to upload our packets to. However, data that w=
e=20
want
=2D * the card to TX needs to stay intact until the card has told us that i=
t is
=2D * done with it. This function finds empty places we can upload to and
+ * can find some unused memory to upload our packets to. However, data tha=
t=20
we
+ * want the card to TX needs to stay intact until the card has told us that
+ * it is done with it. This function finds empty places we can upload to a=
nd
  * marks allocated areas as reserved if necessary. p54_rx_frame_sent frees
  * allocated areas.
  */
diff --git a/drivers/net/wireless/d80211/p54/prism54common.h=20
b/drivers/net/wireless/d80211/p54/prism54common.h
index e2c1ff4..15199f6 100644
=2D-- a/drivers/net/wireless/d80211/p54/prism54common.h
+++ b/drivers/net/wireless/d80211/p54/prism54common.h
@@ -43,6 +43,8 @@ #define FW_LM86 0x4c4d3836
 #define FW_LM87 0x4c4d3837
 #define FW_LM20 0x4c4d3230
=20
+/* PDA defines are Copyright (C) 2005 Nokia Corporation (taken from=20
islsm_pda.h) */
+
 struct pda_entry {
 	u16 len;	/* includes both code and data */
 	u16 code;

--nextPart2458614.4h5U19AnSe
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFNxmzT3Oqt9AH4aERAikYAJwOIAqTopiW6aasl/9Iikh+XRT1RACgrKrU
JqiBSKAgruZDg/qvPELTrb0=
=174h
-----END PGP SIGNATURE-----

--nextPart2458614.4h5U19AnSe--
