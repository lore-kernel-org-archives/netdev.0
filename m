From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bgmac: Fix infinite loop in bgmac_dma_tx_add()
Date: Fri, 15 Jul 2016 15:42:52 -0700
Message-ID: <1468622572-15443-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, zajec5@gmail.com, hauke@hauke-m.de,
	jon.mason@broadcom.com, bcm-kernel-feedback-list@broadcom.com,
	nbd@nbd.name, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35326 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGOWmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:42:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id t190so7040944pfb.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:42:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing is decrementing the index "i" while we are cleaning up the
fragments we could not successful transmit.

Fixes: 9cde94506eacf ("bgmac: implement scatter/gather support")
Reported-by: coverity (CID 1352048)
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index a6333d38ecc0..25bbae5928d4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -231,7 +231,7 @@ err_dma:
 	dma_unmap_single(dma_dev, slot->dma_addr, skb_headlen(skb),
 			 DMA_TO_DEVICE);
 
-	while (i > 0) {
+	while (i-- > 0) {
 		int index = (ring->end + i) % BGMAC_TX_RING_SLOTS;
 		struct bgmac_slot_info *slot = &ring->slots[index];
 		u32 ctl1 = le32_to_cpu(ring->cpu_base[index].ctl1);
-- 
2.7.4
