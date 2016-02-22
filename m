From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
Date: Mon, 22 Feb 2016 14:49:33 +0800
Message-ID: <1456123773-1016-4-git-send-email-yangbo.lu@nxp.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:13426
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751855AbcBVHM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 02:12:59 -0500
In-Reply-To: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..20e8648 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2708,6 +2708,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 *ns = (u64 *)(((uintptr_t)skb->data + 0x10) &
 					  ~0x7UL);
+			*ns = be64_to_cpu(*ns);
 
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
@@ -3037,6 +3038,7 @@ static void gfar_process_frame(struct net_device *ndev, struct sk_buff *skb)
 	if (priv->hwts_rx_en) {
 		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 		u64 *ns = (u64 *) skb->data;
+		*ns = be64_to_cpu(*ns);
 
 		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
-- 
2.1.0.27.g96db324
