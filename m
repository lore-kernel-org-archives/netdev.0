From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 2/6] forcedeth: remove unnecessary checks before kfree
Date: Sat, 27 Nov 2010 19:39:44 +0100
Message-ID: <1290883188-2078-3-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56863 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218Ab0K0SvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:01 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id DEB65801AF57
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:49 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 87757c8..81722fb 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1013,10 +1013,8 @@ static void free_rings(struct net_device *dev)
 			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (np->rx_ring_size + np->tx_ring_size),
 					    np->rx_ring.ex, np->ring_addr);
 	}
-	if (np->rx_skb)
-		kfree(np->rx_skb);
-	if (np->tx_skb)
-		kfree(np->tx_skb);
+	kfree(np->rx_skb);
+	kfree(np->tx_skb);
 }
 
 static int using_multi_irqs(struct net_device *dev)
@@ -4442,10 +4440,9 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 				pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (ring->rx_pending + ring->tx_pending),
 						    rxtx_ring, ring_addr);
 		}
-		if (rx_skbuff)
-			kfree(rx_skbuff);
-		if (tx_skbuff)
-			kfree(tx_skbuff);
+
+		kfree(rx_skbuff);
+		kfree(tx_skbuff);
 		goto exit;
 	}
 
-- 
1.7.2.3


