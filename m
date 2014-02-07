From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] wan: dlci: Remove unused netdev_priv pointer
Date: Sat, 8 Feb 2014 00:21:10 +0100
Message-ID: <20140208002110.56c980e9@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/t+uVP969yb=I/rgH+T9MCMU"; protocol="application/pgp-signature"
Cc: David Miller <davem@davemloft.net>, Zefan Li <lizefan@huawei.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:57761 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbaBGXVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 18:21:15 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx103) with ESMTPSA
 (Nemesis) id 0Lwarz-1V9L7A0zOx-018GGz for <netdev@vger.kernel.org>; Sat, 08
 Feb 2014 00:21:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/t+uVP969yb=I/rgH+T9MCMU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Remove occurrences of unused pointer to network device private data in
functions dlci_header() and dlci_receive().

Detected by Coverity: CID 139844, CID 139845.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
 drivers/net/wan/dlci.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 0d1c759..19f7cb2 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -71,12 +71,9 @@ static int dlci_header(struct sk_buff *skb, struct net_d=
evice *dev,
 		       const void *saddr, unsigned len)
 {
 	struct frhdr		hdr;
-	struct dlci_local	*dlp;
 	unsigned int		hlen;
 	char			*dest;
=20
-	dlp =3D netdev_priv(dev);
-
 	hdr.control =3D FRAD_I_UI;
 	switch (type)
 	{
@@ -107,11 +104,9 @@ static int dlci_header(struct sk_buff *skb, struct net=
_device *dev,
=20
 static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dlci_local *dlp;
 	struct frhdr		*hdr;
 	int					process, header;
=20
-	dlp =3D netdev_priv(dev);
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
 		netdev_notice(dev, "invalid data no header\n");
 		dev->stats.rx_errors++;
--=20
1.8.3.2


--Sig_/t+uVP969yb=I/rgH+T9MCMU
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJS9WpmAAoJEKssnEpaPQKE+VAP/AzQUyoKHbCVEHXM1xSSboPQ
9S4IIkUjefRKoop0C0z7cQy5lfTbccYOfzdMWByVSUYhwW1yUDymiSb59qEGvfyJ
ve+8w4yGkl5GMRpCZQrTBqtEFH6dhDOb38kHOFI7N03Wg7085cISx/GgR2G4SpVU
EqwfjKQSsh92ot3HhNXEy3g390NLxEH3vdZXHra/pkRmPQveUL4VmkxuDM/TuDn4
z5goZPXMbWu0GCF8hSaO+VBb0acOMKC9NzYYhI83KvCSIg+KE2LH/6g2x15B5tyI
ytBIb4uLoVooJDZaI49mUziLGOjh4ezIWwYT2pQraFOclN35ibkjaV4Z7jgwApMm
qjb4BRV8MFXjdJKFnuSixrP7TUC92x8fnjahaTg9MYbltfoOz1l2usFuIDFLkiva
wOs59N6RXbjuc1PoQbs7NBkELhwGuGY+vQicROVKlaDjqLDS4oBfbXgW3EhgQWmp
Oz2yhlDeZgP8o2yl6RM7Y1CoEcHGa8MLEKumyzp1LNFc9D2WJY0LoLxcGhD99AgV
vix9D52nIVoxB+/RQkrdMkgfbqSFesd4gfRagnzk9slE5xPuxsZD3ZqMkFgOL/q7
xr1J9NCCH6j3bWXUhzCI+WZmlw+E+0ZkI0agSD9kG46eusuDH1kqHEMyI3AJzFIA
PXhLonZyGiB8UBcbxaWD
=K9Yo
-----END PGP SIGNATURE-----

--Sig_/t+uVP969yb=I/rgH+T9MCMU--
