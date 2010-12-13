From: Yoichi Yuasa <yuasa@linux-mips.org>
Subject: [PATCH net-next-2.6 1/2] cpmac: remove unused buflen
Date: Mon, 13 Dec 2010 17:17:25 +0900
Message-ID: <20101213171725.2ed299cf.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yuasa@linux-mips.org, netdev <netdev@vger.kernel.org>,
	Eugene Konev <ejka@imfi.kspu.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50963 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0LMIUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 03:20:05 -0500
Received: by yxt3 with SMTP id 3so3125584yxt.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 00:20:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
---
 drivers/net/cpmac.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index fec939f..8021756 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -179,7 +179,6 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 struct cpmac_desc {
 	u32 hw_next;
 	u32 hw_data;
-	u16 buflen;
 	u16 bufflags;
 	u16 datalen;
 	u16 dataflags;
@@ -415,7 +414,6 @@ static struct sk_buff *cpmac_rx_one(struct cpmac_priv *priv,
 		priv->dev->stats.rx_dropped++;
 	}
 
-	desc->buflen = CPMAC_SKB_SIZE;
 	desc->dataflags = CPMAC_OWN;
 
 	return result;
@@ -586,7 +584,6 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					    DMA_TO_DEVICE);
 	desc->hw_data = (u32)desc->data_mapping;
 	desc->datalen = len;
-	desc->buflen = len;
 	if (unlikely(netif_msg_tx_queued(priv)))
 		printk(KERN_DEBUG "%s: sending 0x%p, len=%d\n", dev->name, skb,
 		       skb->len);
@@ -1005,7 +1002,6 @@ static int cpmac_open(struct net_device *dev)
 						    CPMAC_SKB_SIZE,
 						    DMA_FROM_DEVICE);
 		desc->hw_data = (u32)desc->data_mapping;
-		desc->buflen = CPMAC_SKB_SIZE;
 		desc->dataflags = CPMAC_OWN;
 		desc->next = &priv->rx_head[(i + 1) % priv->ring_size];
 		desc->next->prev = desc;
-- 
1.7.3.3

