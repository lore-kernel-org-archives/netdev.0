From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/8] e1000e: Add GRO support
Date: Fri, 12 Dec 2008 16:31:57 +1100
Message-ID: <E1LB0d3-0000rz-Gx@gondolin.me.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59012 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758016AbYLLFcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:32:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e: Add GRO support

This patch adds GRO support to e1000e by making it invoke napi_gro_receive
instead of netif_receive_skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91795f7..fb7c4bd 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -102,7 +102,7 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 					 le16_to_cpu(vlan));
 	else
-		netif_receive_skb(skb);
+		napi_gro_receive(&adapter->napi, skb);
 
 	netdev->last_rx = jiffies;
 }
