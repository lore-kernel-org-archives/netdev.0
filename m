From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the  tree
Date: Wed, 21 Dec 2011 12:49:31 +1100
Message-ID: <20111221124931.992e4e4265f2c3cd1d2e75b4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__21_Dec_2011_12_49_31_+1100_dTnpmGLCfTatxGKm"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Franky Lin <frankyl@broadcom.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from calzone.tip.net.au ([203.10.76.15]:34764 "EHLO
	calzone.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab1LUBtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 20:49:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__21_Dec_2011_12_49_31_+1100_dTnpmGLCfTatxGKm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c between commit
3db1cd5c05f3 ("net: fix assignment of 0/1 to bool variables") from the
tree and commit 3fb1d8d2dad3 ("brcm80211: fmac: move driver up status to
struct brcmf_bus") from the wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 2c3a99d,72bee2c..0000000
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@@ -805,7 -784,7 +784,7 @@@ static int brcmf_netdev_stop(struct net
  		return 0;
 =20
  	/* Set state and stop OS transmissions */
- 	drvr->up =3D false;
 -	drvr->bus_if->drvr_up =3D 0;
++	drvr->bus_if->drvr_up =3D false;
  	netif_stop_queue(ndev);
 =20
  	return 0;
@@@ -842,8 -821,8 +821,8 @@@ static int brcmf_netdev_open(struct net
  	}
  	/* Allow transmit calls */
  	netif_start_queue(ndev);
- 	drvr_priv->pub.up =3D true;
- 	if (brcmf_cfg80211_up(drvr_priv->pub.config)) {
 -	drvr->bus_if->drvr_up =3D 1;
++	drvr->bus_if->drvr_up =3D true;
+ 	if (brcmf_cfg80211_up(drvr->config)) {
  		brcmf_dbg(ERROR, "failed to bring up cfg80211\n");
  		return -1;
  	}

--Signature=_Wed__21_Dec_2011_12_49_31_+1100_dTnpmGLCfTatxGKm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO8TsrAAoJEECxmPOUX5FESNkP/2ns12RFGl7HEov//PQkFrHZ
1Go9JvHlvZERDosFgsOx2ZMrj/HSwLE+bePpYi+TVQh3quUFk25JAGMZITjdqNRy
RaI2v5S8LtLtUnaNxSSOtqSzuFqCh6fMWuy+hBTJbC+f4CY+z66KUbiVZlqIGH7g
mlrYdg6hUw6PFgTzL/kbd8xgwvzDyj/pYUm3y5IDs0bSNFB9V2LD9aHaGCPXoTlj
/X7X1PAblhWhjJeyTnHA18Qrg8Qgz7EUGnF2NgIc1fmkUrGnmXatdIhILaOq4JhR
+2RC43sXS4jjZKIMCasRy/TN4kUOUpZ/50fUWs/KtEhAcCqyfa1FyLO8FFybASPx
FTCnZhX/1B8M/1gWwBXEYCto+gzvGQzQN6OiBj77IV1YE2LGsrSa4H1uk4etJZjl
G3s3HsbJrKzTIn8aYHo8POQFW8U+i5J92FAWGiW/XI+wde6I9DA/lKfyO/2tR7wV
o/DR6zajzstqX9E7N/QUc65Ydrzvq9XAi3efO2nlaXL6aLXPWCa6lHJ50rqJJTCI
sbJ8u3RZD5BiSPuvKB2gsvmuEnsI0Ka+K0Hjks3AkFiIHyplKLH1GJ7OL+ir3kXD
2xG7Zc+U5OOVhjSlX+SdyOph5JpWLyXyYs+J8zd5zwL7DXBzm6zUlWGPznb73D+M
QEQEpffpU0C0ZoYLaQVR
=fK20
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Dec_2011_12_49_31_+1100_dTnpmGLCfTatxGKm--
