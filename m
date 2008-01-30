From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 7/8] [Blackfin] EMAC driver: fix bug - invalidate data cache of new_skb->data range when cache is WB
Date: Wed, 30 Jan 2008 16:52:27 +0800
Message-ID: <1201683148-23931-8-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org, Alexey Demin <bf53x@ya.ru>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:47051 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745AbYA3Iwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:39 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Demin <bf53x@ya.ru>

It prevents overwritting new data from DMA.

Signed-off-by: Alexey Demin <bf53x@ya.ru>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index f2368b7..0a17fb4 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -651,6 +651,12 @@ static void bf537mac_rx(struct net_device *dev)
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
+	/* Invidate the data cache of skb->data range when it is write back
+	 * cache. It will prevent overwritting the new data from DMA
+	 */
+	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
+					 (unsigned long)new_skb->end);
+
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
 	skb_put(skb, len);
 	blackfin_dcache_invalidate_range((unsigned long)skb->head,
-- 
1.5.3.4
