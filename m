From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for Tx timestamping
Date: Mon, 29 Apr 2013 15:57:48 +0300
Message-ID: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:34760
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757353Ab3D2M6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 08:58:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Tx timestamping is enabled the number of sent bytes reported
to BQL via tx_completed_queue() falls short by GMAC_FCB_LEN +
GMAC_TXPAL_LEN than the number of bytes reported via tx_sent_queue()
on xmit. This leads to BQL stopping transmission errorneously followed
by tx timeout firing.

This fixes the amount of sent bytes reported to BQL on clean_tx_ring
to match the amount reported on xmit, when Tx timestamping enabled.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2375a01..0d26a8b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2539,6 +2539,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			skb_tstamp_tx(skb, &shhwtstamps);
 			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 			bdp = next;
+			bytes_sent += GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 		}
 
 		bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
-- 
1.7.11.3
