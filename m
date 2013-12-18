From: Tom Herbert <therbert@google.com>
Subject: [PATCH 15/15] net: vmxnet3 calls skb_set_hash
Date: Tue, 17 Dec 2013 23:32:08 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172328170.11882@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:60681 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRHcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:32:10 -0500
Received: by mail-ve0-f201.google.com with SMTP id jw12so736854veb.4
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:32:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index a300a18..c0eab72 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1235,7 +1235,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 #ifdef VMXNET3_RSS
 			if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
 			    (adapter->netdev->features & NETIF_F_RXHASH))
-				ctx->skb->rxhash = le32_to_cpu(rcd->rssHash);
+				skb_set_hash(skb, le32_to_cpu(rcd->rssHash),
+					     PKT_HASH_TYPE_L3);
 #endif
 			skb_put(ctx->skb, rcd->len);
 
-- 
1.8.5.1
