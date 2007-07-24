From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] Au1000 eth : fix ioctl handling
Date: Tue, 24 Jul 2007 11:15:50 +0200
Message-ID: <200707241115.51486.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1673633.7zb1yToEVD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.int-evry.fr ([157.159.10.44]:59340 "EHLO
	smtp1.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933441AbXGXJr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 05:47:29 -0400
Received: from smtp-ext.int-evry.fr (smtp-ext.int-evry.fr [157.159.11.17])
	by smtp1.int-evry.fr (Postfix) with ESMTP id 772E68E678E
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 11:15:37 +0200 (CEST)
Received: from [192.168.2.196] (mla78-1-82-240-16-241.fbx.proxad.net [82.240.16.241])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-ext.int-evry.fr (Postfix) with ESMTP id 4D2A48D15E8
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 11:15:37 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1673633.7zb1yToEVD
Content-Type: multipart/mixed;
  boundary="Boundary-01=_HNcpGVWvzWHX6i1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_HNcpGVWvzWHX6i1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

This patch fixes the handling of unsupported ioctls with the au1000_eth=20
driver.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
=2D-=20

--Boundary-01=_HNcpGVWvzWHX6i1
Content-Type: text/plain;
  charset="us-ascii";
  name="au1000_eth_ioctl.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="au1000_eth_ioctl.patch"

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index c27cfce..99a1c61 100644
=2D-- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1316,12 +1316,20 @@ static void set_rx_mode(struct net_device *dev)
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct au1000_private *aup =3D (struct au1000_private *)dev->priv;
+	struct mii_ioctl_data *data =3D if_mii(rq);
+	int rc =3D -EOPNOTSUPP;
=20
 	if (!netif_running(dev)) return -EINVAL;
=20
 	if (!aup->phy_dev) return -EINVAL; // PHY not controllable
=20
=2D	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
+	switch (cmd) {
+	default:
+		rc =3D phy_mii_ioctl(aup->phy_dev, data, cmd);
+		break;
+	}
+
+	return rc;
 }
=20
 static struct net_device_stats *au1000_get_stats(struct net_device *dev)

--Boundary-01=_HNcpGVWvzWHX6i1--

--nextPart1673633.7zb1yToEVD
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD8DBQBGpcNHmx9n1G/316sRAoqcAKDkvQeXi+wQ+pZdgWCig1mI+fTEHwCeNxwC
9u5O6Zw8zb+UcAnE3z5RGZg=
=gjNP
-----END PGP SIGNATURE-----

--nextPart1673633.7zb1yToEVD--
