From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH] fs_enet: restore promiscuous and multicast settings in restart()
Date: Wed, 18 Jun 2008 17:07:07 +0200
Message-ID: <200806181707.17739.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1386118.M8y5TnNNF1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:13852 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729AbYFRPHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1386118.M8y5TnNNF1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

The restart() function is called when the link state changes and resets
multicast and promiscous settings. This patch restores those settings at the
end of restart().

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
=2D--
 drivers/net/fs_enet/mac-fcc.c     |    3 +++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index ce40cf9..1a95cf1 100644
=2D-- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
 		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
=20
 	S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
+
+	/* Restore multicast and promiscous settings */
+	set_multicast_list(dev);
 }
=20
 static void stop(struct net_device *dev)
=2D-=20
1.5.0

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart1386118.M8y5TnNNF1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIWSSl8y9gWxC9vpcRAuYCAKDT9dcrHrpeZyli5c9AFpUr2ALLxQCgx95Z
itlXbHcTrA/+ZK8T6WbE0Qg=
=Wu/5
-----END PGP SIGNATURE-----

--nextPart1386118.M8y5TnNNF1--
