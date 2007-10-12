From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: Fix compile regression caused by bea3348e
Date: Fri, 12 Oct 2007 21:53:51 +0800
Message-ID: <1192197233-24958-1-git-send-email-leoli@freescale.com>
Cc: Li Yang <leoli@freescale.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:49864 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbXJLNnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 09:43:31 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l9CDhTxc015971
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 06:43:29 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l9CDhPSZ011003
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 08:43:28 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0db5e6f..2b758fa 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -261,7 +261,9 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->hard_start_xmit = gfar_start_xmit;
 	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_GFAR_NAPI
 	netif_napi_add(dev, &priv->napi, gfar_poll, GFAR_DEV_WEIGHT);
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = gfar_netpoll;
 #endif
@@ -931,6 +933,7 @@ tx_skb_fail:
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
 {
+	struct gfar_private *priv = netdev_priv(dev);
 	int err;
 
 	napi_enable(&priv->napi);
-- 
1.5.3.2.104.g41ef

