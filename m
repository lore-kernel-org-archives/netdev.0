From: Tom Herbert <therbert@google.com>
Subject: [PATCH 06/15] net: e1000e calls skb_set_hash
Date: Tue, 17 Dec 2013 23:27:16 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172326360.24380@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:59307 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab3LRH1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:27:18 -0500
Received: by mail-vb0-f74.google.com with SMTP id w5so736590vbf.1
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:27:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 051d158..098fb7d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -885,7 +885,7 @@ static inline void e1000_rx_hash(struct net_device *netdev, __le32 rss,
 				 struct sk_buff *skb)
 {
 	if (netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rss);
+		skb_set_hash(skb, le32_to_cpu(rss), PKT_HASH_TYPE_L3);
 }
 
 /**
-- 
1.8.5.1
