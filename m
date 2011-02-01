From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] depca: Fix warnings
Date: Tue, 01 Feb 2011 11:32:29 +0000
Message-ID: <20110201113214.24608.34659.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:37046 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab1BAMAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 07:00:06 -0500
Received: from bob.linux.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.4/8.14.1) with ESMTP id p11Bx6Wx009089
	for <netdev@vger.kernel.org>; Tue, 1 Feb 2011 11:59:11 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Replace the rather weird use of ++ with + 1 as the value is being assigned

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/depca.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 1b48b68..8b0084d 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1094,7 +1094,7 @@ static int depca_rx(struct net_device *dev)
 				}
 			}
 			/* Change buffer ownership for this last frame, back to the adapter */
-			for (; lp->rx_old != entry; lp->rx_old = (++lp->rx_old) & lp->rxRingMask) {
+			for (; lp->rx_old != entry; lp->rx_old = (lp->rx_old + 1) & lp->rxRingMask) {
 				writel(readl(&lp->rx_ring[lp->rx_old].base) | R_OWN, &lp->rx_ring[lp->rx_old].base);
 			}
 			writel(readl(&lp->rx_ring[entry].base) | R_OWN, &lp->rx_ring[entry].base);
@@ -1103,7 +1103,7 @@ static int depca_rx(struct net_device *dev)
 		/*
 		   ** Update entry information
 		 */
-		lp->rx_new = (++lp->rx_new) & lp->rxRingMask;
+		lp->rx_new = (lp->rx_new + 1) & lp->rxRingMask;
 	}
 
 	return 0;
@@ -1148,7 +1148,7 @@ static int depca_tx(struct net_device *dev)
 		}
 
 		/* Update all the pointers */
-		lp->tx_old = (++lp->tx_old) & lp->txRingMask;
+		lp->tx_old = (lp->tx_old + 1) & lp->txRingMask;
 	}
 
 	return 0;

