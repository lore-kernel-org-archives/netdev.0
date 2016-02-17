From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] geneve: clear IFF_TX_SKB_SHARING
Date: Wed, 17 Feb 2016 15:31:35 +0100
Message-ID: <ff77ee3522f56d1f4ab4381fca130978c0d3fca4.1455719425.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423215AbcBQObw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 09:31:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether_setup sets IFF_TX_SKB_SHARING but this is not supported by geneve as
it modifies the skb on xmit.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/geneve.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 028e3873c310..085b27cefb74 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1161,6 +1161,7 @@ static void geneve_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
 
 	netif_keep_dst(dev);
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	eth_hw_addr_random(dev);
 }
-- 
1.8.3.1
