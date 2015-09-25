From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: Remove unneeded FEATURES_NEED_QUIESCE definition
Date: Fri, 25 Sep 2015 18:31:32 -0300
Message-ID: <1443216692-29042-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36366 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755457AbbIYVb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:31:56 -0400
Received: by qgx61 with SMTP id 61so80245316qgx.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 14:31:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is no need to have FEATURES_NEED_QUIESCE defined as we
can simply use NETIF_F_RXCSUM instead as done in other parts
of the driver.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index dd4ca39..501e143 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3070,7 +3070,6 @@ static void fec_poll_controller(struct net_device *dev)
 }
 #endif
 
-#define FEATURES_NEED_QUIESCE NETIF_F_RXCSUM
 static inline void fec_enet_set_netdev_features(struct net_device *netdev,
 	netdev_features_t features)
 {
@@ -3094,7 +3093,7 @@ static int fec_set_features(struct net_device *netdev,
 	struct fec_enet_private *fep = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
-	if (netif_running(netdev) && changed & FEATURES_NEED_QUIESCE) {
+	if (netif_running(netdev) && changed & NETIF_F_RXCSUM) {
 		napi_disable(&fep->napi);
 		netif_tx_lock_bh(netdev);
 		fec_stop(netdev);
-- 
1.9.1
