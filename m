From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: systemport: Utilize skb_put_padto()
Date: Tue,  3 Jan 2017 16:34:48 -0800
Message-ID: <20170104003449.27078-2-f.fainelli@gmail.com>
References: <20170104003449.27078-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34403 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762206AbdADAfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 19:35:40 -0500
Received: by mail-pg0-f65.google.com with SMTP id b1so35073395pgc.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 16:35:01 -0800 (PST)
In-Reply-To: <20170104003449.27078-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we need to pad our packets, utilize skb_put_padto() which
increases skb->len by how much we need to pad, allowing us to eliminate
the test on skb->len right below.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 25d1eb4933d0..e67908b5edfe 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1028,13 +1028,12 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
 	 * (including FCS and tag) because the length verification is done after
 	 * the Broadcom tag is stripped off the ingress packet.
 	 */
-	if (skb_padto(skb, ETH_ZLEN + ENET_BRCM_TAG_LEN)) {
+	if (skb_put_padto(skb, ETH_ZLEN + ENET_BRCM_TAG_LEN)) {
 		ret = NETDEV_TX_OK;
 		goto out;
 	}
 
-	skb_len = skb->len < ETH_ZLEN + ENET_BRCM_TAG_LEN ?
-			ETH_ZLEN + ENET_BRCM_TAG_LEN : skb->len;
+	skb_len = skb->len;
 
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	if (dma_mapping_error(kdev, mapping)) {
-- 
2.9.3
