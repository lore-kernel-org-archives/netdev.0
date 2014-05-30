From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 1/8] net: mvneta: Use default NAPI weight instead of a custom one
Date: Fri, 30 May 2014 13:40:04 -0300
Message-ID: <1401468011-10609-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58412 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756103AbaE3QlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:07 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has no need for a custom NAPI weigth. Use the default
one, which has the same value.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b8919fa..af1ac82 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -219,9 +219,6 @@
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
-/* Napi polling weight */
-#define MVNETA_RX_POLL_WEIGHT		64
-
 /* The two bytes Marvell header. Either contains a special value used
  * by Marvell switches when a specific hardware mode is enabled (not
  * supported by this driver) or is filled automatically by zeroes on
@@ -3025,7 +3022,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	if (dram_target_info)
 		mvneta_conf_mbus_windows(pp, dram_target_info);
 
-	netif_napi_add(dev, &pp->napi, mvneta_poll, MVNETA_RX_POLL_WEIGHT);
+	netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);
 
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
-- 
1.9.1
