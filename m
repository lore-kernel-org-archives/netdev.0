From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: [PATCH] via-rhine: fix full-duplex with autoneg disable
Date: Thu, 12 Jun 2014 12:11:25 +0200
Message-ID: <53997CCD.4010200@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.cachereul@alphalink.fr, netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52247 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932878AbaFLKR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 06:17:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some specific configuration (VT6105M on Soekris 5510 and depending
on the device at the other end), fragmented packets were not transmitte=
d
when forcing 100 full-duplex with autoneg disable.

This fix now write full-duplex chips register when forcing full or
half-duplex not only when autoneg is enable.

Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
---
 drivers/net/ethernet/via/via-rhine.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/etherne=
t/via/via-rhine.c
index f61dc2b..25bb25b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1278,8 +1278,9 @@ static void rhine_set_carrier(struct mii_if_info =
*mii)
 		/* autoneg is off: Link is always assumed to be up */
 		if (!netif_carrier_ok(dev))
 			netif_carrier_on(dev);
-	} else	/* Let MMI library update carrier status */
-		rhine_check_media(dev, 0);
+	}
+
+	rhine_check_media(dev, 0);
=20
 	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
 		   mii->force_media, netif_carrier_ok(dev));
--=20
1.7.10.4
