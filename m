From: Erik Mouw <mouw@nl.linux.org>
Subject: [PATCH] xircom_cb should return NETDEV_TX_BUSY when there are no
	descriptors available
Date: Mon, 4 Feb 2008 18:56:54 +0100
Message-ID: <20080204175653.GC16952@gateway.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XMCwj5IQnwKtuyBG"
Cc: netdev@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	jamal <hadi@cyberus.ca>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr8.xs4all.nl ([194.109.24.28]:2108 "EHLO
	smtp-vbr8.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbYBDR5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 12:57:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--XMCwj5IQnwKtuyBG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Changes in other networking paths uncovered a bug in the xircom_cb
driver which made the kernel spew lots of the following error messages:

  BUG eth1 code -5 qlen 0

It turned out that the driver returned -EIO when there was no
descriptor available for sending packets. It should return
NETDEV_TX_BUSY instead. This was discussed on the netdev list before,
see http://thread.gmane.org/gmane.linux.network/84603 .

Signed-off-by: Erik Mouw <mouw@nl.linux.org>

diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 8fc7274..6b93d01 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -441,7 +441,7 @@ static int xircom_start_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 	spin_unlock_irqrestore(&card->lock,flags);
 	trigger_transmit(card);
=20
-	return -EIO;
+	return NETDEV_TX_BUSY;
 }
=20
=20


--XMCwj5IQnwKtuyBG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHp1Hl/PlVHJtIto0RAoIIAKCEf4bOYCvCbkN0lNZbBD9POyFbDACfX78t
2BIUj9eN4+rsmhh5csQDkq0=
=3wd5
-----END PGP SIGNATURE-----

--XMCwj5IQnwKtuyBG--
