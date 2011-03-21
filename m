From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC addresses.
Date: Mon, 21 Mar 2011 17:37:36 +0100
Message-ID: <a6ba75577552abe8d5045434030c276d5f45779a.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <cae922ff2a4ba144baf3d50f5d9fddd13d50e68b.1300724245.git.LW@KARO-electronics.de>
 <264d7eca14554038e57399850ddd7fa4491a7484.1300724245.git.LW@KARO-electronics.de>
 <e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58257 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab1CUQk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:40:29 -0400
In-Reply-To: <e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
In-Reply-To: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC driver currently uses the MAC address assigned to the first
interface incremented by one for the second interface.

Change this to be able to configure distinct MAC addresses via
platform_data.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/fec.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3666524..9d89e99 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -750,13 +750,12 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
 	/*
 	 * 2) from flash or fuse (via platform data)
 	 */
+	if (pdata)
+		memcpy(iap, pdata->mac, ETH_ALEN);
 	if (!is_valid_ether_addr(iap)) {
 #ifdef CONFIG_M5272
 		if (FEC_FLASHMAC)
 			iap =3D (unsigned char *)FEC_FLASHMAC;
-#else
-		if (pdata)
-			memcpy(iap, pdata->mac, ETH_ALEN);
 #endif
 	}
=20
@@ -772,10 +771,6 @@ static void __inline__ fec_get_mac(struct net_devi=
ce *ndev)
 	}
=20
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using macaddr */
-	if (iap =3D=3D macaddr)
-		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev->id;
 }
=20
 /* -------------------------------------------------------------------=
------ */
--=20
1.5.6.5

