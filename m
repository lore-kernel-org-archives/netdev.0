From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 09/11] net:fec: remove unnessary memory copy for address alignment in .xmit()
Date: Thu, 4 Sep 2014 04:34:44 +0800
Message-ID: <38923.2663008899$1409778761@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0098.outbound.protection.outlook.com ([157.56.111.98]:52710
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755923AbaICVMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:12:18 -0400
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

i.MX6SX enet-avb IP support buffer address byte alignment for tx DMA
transfer, so remove the unnessary memory copy for the enet avb IP.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b388e29f..d09fe16 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -518,8 +518,9 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	queue = skb_get_queue_mapping(skb);
 	index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
-	if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
-		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
+	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB) &&
+	    ((((unsigned long)bufaddr) & FEC_ALIGNMENT ||
+		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME))) {
 		memcpy(txq->tx_bounce[index], skb->data, buflen);
 		bufaddr = txq->tx_bounce[index];
 
-- 
1.9.1
