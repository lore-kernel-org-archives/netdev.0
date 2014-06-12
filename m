From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v5 3/6] net: fec: Factorize feature setting
Date: Thu, 12 Jun 2014 08:16:20 +0800
Message-ID: <1402532183-14910-4-git-send-email-b38611@freescale.com>
References: <1402532183-14910-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:22168
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754528AbaFLBmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 21:42:17 -0400
In-Reply-To: <1402532183-14910-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to enhance the code readable, let's factorize the
feature list.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 55b55d2..f943cd1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2087,21 +2087,19 @@ static int fec_enet_init(struct net_device *ndev)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, NAPI_POLL_WEIGHT);
 
-	if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN) {
+	if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN)
 		/* enable hw VLAN support */
 		ndev->features |= NETIF_F_HW_VLAN_CTAG_RX;
-		ndev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
-	}
 
 	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
 		/* enable hw accelerator */
 		ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
 				| NETIF_F_RXCSUM);
-		ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				| NETIF_F_RXCSUM);
 		fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
 	}
 
+	ndev->hw_features = ndev->features;
+
 	fec_restart(ndev, 0);
 
 	return 0;
-- 
1.7.8
