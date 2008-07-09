From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [FIX] ARM: IXP4xx Ethernet NAPI fix
Date: Wed, 09 Jul 2008 13:10:32 +0200
Message-ID: <m31w23ia8n.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59411 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757056AbYGILKe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 07:10:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some weirdness from IXP4xx Ethernet driver.
Ideally it should go in 2.6.26 though it's not that critical. Thanks.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.=
c
index c617b64..9b777d9 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -522,7 +522,6 @@ static int eth_poll(struct napi_struct *napi, int b=
udget)
 #endif
=20
 		if ((n =3D queue_get_desc(rxq, port, 0)) < 0) {
-			received =3D 0; /* No packet received */
 #if DEBUG_RX
 			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
 			       dev->name);
@@ -543,7 +542,7 @@ static int eth_poll(struct napi_struct *napi, int b=
udget)
 			printk(KERN_DEBUG "%s: eth_poll all done\n",
 			       dev->name);
 #endif
-			return 0; /* all work done */
+			return received; /* all work done */
 		}
=20
 		desc =3D rx_desc_ptr(port, n);
