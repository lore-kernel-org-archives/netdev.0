From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: remove checks around dev_kfree_skb() calls
Date: Sat, 28 Jun 2014 04:10:00 +0400
Message-ID: <201406280410.01146.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:49368 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbaF1AJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:09:44 -0400
Received: by mail-lb0-f170.google.com with SMTP id 10so4505904lbg.1
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 17:09:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since consume_skb() (and hence dev_kfree_skb() macro) checks the passed pointer
for NULL, there's no need to check for NULL before invoking dev_kfree_skb().

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1094,20 +1094,16 @@ static void sh_eth_ring_free(struct net_
 
 	/* Free Rx skb ringbuffer */
 	if (mdp->rx_skbuff) {
-		for (i = 0; i < mdp->num_rx_ring; i++) {
-			if (mdp->rx_skbuff[i])
-				dev_kfree_skb(mdp->rx_skbuff[i]);
-		}
+		for (i = 0; i < mdp->num_rx_ring; i++)
+			dev_kfree_skb(mdp->rx_skbuff[i]);
 	}
 	kfree(mdp->rx_skbuff);
 	mdp->rx_skbuff = NULL;
 
 	/* Free Tx skb ringbuffer */
 	if (mdp->tx_skbuff) {
-		for (i = 0; i < mdp->num_tx_ring; i++) {
-			if (mdp->tx_skbuff[i])
-				dev_kfree_skb(mdp->tx_skbuff[i]);
-		}
+		for (i = 0; i < mdp->num_tx_ring; i++)
+			dev_kfree_skb(mdp->tx_skbuff[i]);
 	}
 	kfree(mdp->tx_skbuff);
 	mdp->tx_skbuff = NULL;
@@ -2077,13 +2073,11 @@ static void sh_eth_tx_timeout(struct net
 		rxdesc = &mdp->rx_ring[i];
 		rxdesc->status = 0;
 		rxdesc->addr = 0xBADF00D0;
-		if (mdp->rx_skbuff[i])
-			dev_kfree_skb(mdp->rx_skbuff[i]);
+		dev_kfree_skb(mdp->rx_skbuff[i]);
 		mdp->rx_skbuff[i] = NULL;
 	}
 	for (i = 0; i < mdp->num_tx_ring; i++) {
-		if (mdp->tx_skbuff[i])
-			dev_kfree_skb(mdp->tx_skbuff[i]);
+		dev_kfree_skb(mdp->tx_skbuff[i]);
 		mdp->tx_skbuff[i] = NULL;
 	}
 
