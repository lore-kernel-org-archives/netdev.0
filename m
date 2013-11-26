From: Tom Herbert <therbert@google.com>
Subject: [PATCH 08/17] net: e1000e calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:52:56 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252151460.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:65270 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3KZFw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:52:57 -0500
Received: by mail-ie0-f201.google.com with SMTP id at1so1116560iec.0
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:52:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
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
