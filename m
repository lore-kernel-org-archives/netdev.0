From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] netx-eth: initialize per device spinlock
Date: Wed,  3 Dec 2008 21:54:51 +0100
Message-ID: <1228337691-8140-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37270 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbYLCUy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 15:54:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock used in the netx-eth driver was never properly initialized=
=2E
This was noticed using CONFIG_DEBUG_SPINLOCK=3Dy

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Acked-by: Sascha Hauer <s.hauer@pengutronix.de>

---
 drivers/net/netx-eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index b9bed82..b289a0a 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -401,6 +401,8 @@ static int netx_eth_drv_probe(struct platform_devic=
e *pdev)
 	priv->xmac_base =3D priv->xc->xmac_base;
 	priv->sram_base =3D priv->xc->sram_base;
=20
+	spin_lock_init(&priv->lock);
+
 	ret =3D pfifo_request(PFIFO_MASK(priv->id));
 	if (ret) {
 		printk("unable to request PFIFO\n");
--=20
tg: (ed31348..) t/netx/netx-eth_initialize_spinlock (depends on: rmk/or=
igin)
