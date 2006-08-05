From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] adm8211: Use ieee80211_*_queue functions
Date: Sat, 5 Aug 2006 00:41:58 -0700
Message-ID: <200608050042.03619.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7806055.ZBgZp9q0sX";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:15527 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1422686AbWHEHmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:42:09 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7806055.ZBgZp9q0sX
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

adm8211: Use ieee80211_*_queue functions

This patch fixes the adm8211 to use the ieee80211_*_queue instead of=20
netif_*_queue functions to stop/wake the queue. Otherwise, the wireless sta=
ck=20
happily overflows our tx ring. It also simplifies the some flag setting=20
related to TX queue handling.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 748eb26..339b69c 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -452,7 +452,7 @@ static void adm8211_interrupt_tci(struct
 	}
=20
 	if (priv->cur_tx - dirty_tx < priv->tx_ring_size - 2)
=2D		netif_wake_queue(dev);
+		ieee80211_wake_queue(dev, 0);
=20
 	priv->dirty_tx =3D dirty_tx;
 	spin_unlock(&priv->lock);
@@ -1765,17 +1765,13 @@ static void adm8211_tx_raw(struct net_de
=20
 	spin_lock_irqsave(&priv->lock, flags);
=20
=2D	if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size / 2)
+	if (priv->cur_tx - priv->dirty_tx =3D=3D priv->tx_ring_size / 2)
 		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
=2D	else if (priv->cur_tx - priv->dirty_tx =3D=3D priv->tx_ring_size / 2)
=2D		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
=2D	else if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size - 2)
+	else
 		flag =3D TDES1_CONTROL_LS | TDES1_CONTROL_FS;
=2D	else {
=2D		flag =3D TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
=2D		printk(KERN_DEBUG "%s: Yikes, this shouldn't happen!\n", dev->name);
=2D		netif_stop_queue(dev);
=2D	}
+
+	if (priv->cur_tx - priv->dirty_tx =3D=3D priv->tx_ring_size - 2)
+		ieee80211_stop_queue(dev, 0);
=20
 	entry =3D priv->cur_tx % priv->tx_ring_size;
=20

--nextPart7806055.ZBgZp9q0sX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE1EvLT3Oqt9AH4aERAty3AJ9SiuGxqRXW1aYB1jAfihbrJk/qXACgpm/h
GYq6Dtt2WRWgMzO0ibCqTW4=
=9DXW
-----END PGP SIGNATURE-----

--nextPart7806055.ZBgZp9q0sX--
