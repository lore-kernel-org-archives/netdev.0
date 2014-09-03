From: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [Patch net-next 09/11] net:fec: remove unnessary memory copy for address alignment in .xmit()
Date: Thu, 4 Sep 2014 04:38:15 +0800
Message-ID: <1409776697-1536-10-git-send-email-Frank.Li@freescale.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409776697-1536-1-git-send-email-Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

i.MX6SX enet-avb IP support buffer address byte alignment for tx DMA
transfer, so remove the unnessary memory copy for the enet avb IP.

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
