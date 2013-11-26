From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 17/17] net: vmxnet3 calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:34:47 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260932080.21248@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f73.google.com ([209.85.212.73]:62585 "EHLO
	mail-vb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3KZRes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:34:48 -0500
Received: by mail-vb0-f73.google.com with SMTP id m10so633983vbh.0
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:34:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e2788c..88d8ff8 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1235,7 +1235,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 #ifdef VMXNET3_RSS
 			if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
 			    (adapter->netdev->features & NETIF_F_RXHASH))
-				ctx->skb->rxhash = le32_to_cpu(rcd->rssHash);
+				skb_set_rxhash(skb, le32_to_cpu(rcd->rssHash),
+					       RXHASH_TYPE_L3);
 #endif
 			skb_put(ctx->skb, rcd->len);
 
-- 
1.8.4.1
