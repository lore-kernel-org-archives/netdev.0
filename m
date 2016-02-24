From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v2, 3/3] gianfar: fix endianness for hardware timestamp
Date: Wed, 24 Feb 2016 17:26:56 +0800
Message-ID: <1456306016-29723-4-git-send-email-yangbo.lu@nxp.com>
References: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>,
	Andy Fleming <afleming@gmail.com>,
	"Kumar Gala" <galak@codeaurora.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0070.outbound.protection.outlook.com ([65.55.169.70]:11360
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751373AbcBXJuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:50:32 -0500
In-Reply-To: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix endianness for the 64-bit hardware timestamp value with
be64_to_cpu to support both PowerPC platforms and ARM platforms.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
Changes for v2:
	- Modified commit message
	- Handled endianness like ns_to_ktime(be64_to_cpu(*ns))
---
 drivers/net/ethernet/freescale/gianfar.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..676656c 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2710,7 +2710,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 					  ~0x7UL);
 
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
-			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
+			shhwtstamps.hwtstamp = ns_to_ktime(be64_to_cpu(*ns));
 			skb_pull(skb, GMAC_FCB_LEN + GMAC_TXPAL_LEN);
 			skb_tstamp_tx(skb, &shhwtstamps);
 			gfar_clear_txbd_status(bdp);
@@ -3039,7 +3039,7 @@ static void gfar_process_frame(struct net_device *ndev, struct sk_buff *skb)
 		u64 *ns = (u64 *) skb->data;
 
 		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
-		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
+		shhwtstamps->hwtstamp = ns_to_ktime(be64_to_cpu(*ns));
 	}
 
 	if (priv->padding)
-- 
2.1.0.27.g96db324
