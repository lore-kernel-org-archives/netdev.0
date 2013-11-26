From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 08/17] net: e1000e calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:27:54 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260923020.21143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:42232 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317Ab3KZR1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:27:55 -0500
Received: by mail-yh0-f74.google.com with SMTP id a41so534234yho.3
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:27:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4ef7867..128534f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -885,7 +885,7 @@ static inline void e1000_rx_hash(struct net_device *netdev, __le32 rss,
 				 struct sk_buff *skb)
 {
 	if (netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rss);
+		skb_set_rxhash(skb, le32_to_cpu(rss), RXHASH_TYPE_L3);
 }
 
 /**
-- 
1.8.4.1
