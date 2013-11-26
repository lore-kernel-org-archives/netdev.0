From: Tom Herbert <therbert@google.com>
Subject: [PATCH 17/17] net: vmxnet3 calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:59:05 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252157380.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f74.google.com ([209.85.160.74]:50081 "EHLO
	mail-pb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab3KZF7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:59:06 -0500
Received: by mail-pb0-f74.google.com with SMTP id uo5so743682pbc.1
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:59:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
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
