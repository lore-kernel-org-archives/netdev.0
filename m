From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH] fs_enet: Don't call NAPI functions when NAPI is not used.
Date: Fri, 7 Mar 2008 16:13:12 +0100
Message-ID: <200803071613.17060.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1818887.vyJ5jlCckg";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:20791 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753960AbYCGPNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:13:22 -0500
Received: from smtp.belgium.cse-semaphore.com (localhost [127.0.0.1])
	by smtp.belgium.cse-semaphore.com (Postfix) with ESMTP id 6A195580C
	for <netdev@vger.kernel.org>; Fri,  7 Mar 2008 16:13:19 +0100 (CET)
Received: from pclaurent.belgium.cse-semaphore.com (pclaurent.belgium.cse-semaphore.com [192.168.1.47])
	by smtp.belgium.cse-semaphore.com (Postfix) with ESMTP id 227B657F1
	for <netdev@vger.kernel.org>; Fri,  7 Mar 2008 16:13:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1818887.vyJ5jlCckg
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

fs_enet_close() calls napi_disable() unconditionally. This patch skips the
call when use_napi isn't set.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
=2D--
 drivers/net/fs_enet/fs_enet-main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c=20
b/drivers/net/fs_enet/fs_enet-main.c
index c83bd65..1801ce3 100644
=2D-- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)
=20
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
=2D	napi_disable(&fep->napi);
+	if (fep->fpi->use_napi)
+		napi_disable(&fep->napi);
 	phy_stop(fep->phydev);
=20
 	spin_lock_irqsave(&fep->lock, flags);
=2D-=20
1.5.0

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=E9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1818887.vyJ5jlCckg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBH0VuN8y9gWxC9vpcRAr92AJ9AU7RrejCusDUPUc1Riag9B8uXcgCgy7MQ
sP5sddVkO0kY3V2lLc2dumY=
=cNcp
-----END PGP SIGNATURE-----

--nextPart1818887.vyJ5jlCckg--
