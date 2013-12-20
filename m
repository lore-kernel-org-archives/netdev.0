From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next] vmxnet3: use initialized skb pointer to set hash
Date: Fri, 20 Dec 2013 13:16:57 +0100
Message-ID: <1387541817-7877-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130Ab3LTMRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 07:17:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent conversion to skb_set_hash() was incorrect. 'skb' is
uninitialized at this point.

Fixes: 0b6807034791 ('net: vmxnet3 calls skb_set_hash')
Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c0eab72..3be786f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1235,7 +1235,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 #ifdef VMXNET3_RSS
 			if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
 			    (adapter->netdev->features & NETIF_F_RXHASH))
-				skb_set_hash(skb, le32_to_cpu(rcd->rssHash),
+				skb_set_hash(ctx->skb,
+					     le32_to_cpu(rcd->rssHash),
 					     PKT_HASH_TYPE_L3);
 #endif
 			skb_put(ctx->skb, rcd->len);
-- 
1.8.4.2
