From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: Fix regression caused by new napi interface
Date: Mon, 15 Oct 2007 23:01:12 +0800
Message-ID: <1192460472-27099-1-git-send-email-leoli@freescale.com>
Cc: Li Yang <leoli@freescale.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:45011 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbXJOOuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 10:50:51 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l9FEonk2004706
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 07:50:49 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l9FEoieJ005328
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 09:50:45 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Protect all new napi function calls with CONFIG_GFAR_NAPI.  Otherwise
the driver will stop working when CONFIG_GFAR_NAPI disabled.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c15fb1f..cc288d8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -932,10 +932,14 @@ tx_skb_fail:
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
 {
+#ifdef CONFIG_GFAR_NAPI
 	struct gfar_private *priv = netdev_priv(dev);
+#endif
 	int err;
 
+#ifdef CONFIG_GFAR_NAPI
 	napi_enable(&priv->napi);
+#endif
 
 	/* Initialize a bunch of registers */
 	init_registers(dev);
@@ -945,13 +949,17 @@ static int gfar_enet_open(struct net_device *dev)
 	err = init_phy(dev);
 
 	if(err) {
+#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
+#endif
 		return err;
 	}
 
 	err = startup_gfar(dev);
 	if (err)
+#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
+#endif
 
 	netif_start_queue(dev);
 
@@ -1105,7 +1113,9 @@ static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
+#ifdef CONFIG_GFAR_NAPI
 	napi_disable(&priv->napi);
+#endif
 
 	stop_gfar(dev);
 
-- 
1.5.3.2.104.g41ef

