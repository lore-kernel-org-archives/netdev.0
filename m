From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Use NAPI_POLL_WEIGHT
Date: Tue, 27 Aug 2013 17:33:18 -0300
Message-ID: <1377635598-10113-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f179.google.com ([209.85.213.179]:54667 "EHLO
	mail-ye0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab3H0U4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:56:36 -0400
Received: by mail-ye0-f179.google.com with SMTP id l10so1349235yen.24
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:56:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Instead of using a custom 'NAPI_POLL_WEIGHT', just use the generic
'NAPI_POLL_WEIGHT' definition instead.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fdf9307..c88a129 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -69,7 +69,6 @@ static void set_multicast_list(struct net_device *ndev);
 #endif
 
 #define DRIVER_NAME	"fec"
-#define FEC_NAPI_WEIGHT	64
 
 /* Pause frame feild and FIFO threshold */
 #define FEC_ENET_FCE	(1 << 5)
@@ -1981,7 +1980,7 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
-	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
+	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, NAPI_POLL_WEIGHT);
 
 	if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN) {
 		/* enable hw VLAN support */
-- 
1.8.1.2
