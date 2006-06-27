From: Brent Cook <bcook@bpointsys.com>
Subject: [PATCH 2/3] mv643xx fixes - Increment TX bytes statistics counter
Date: Tue, 27 Jun 2006 09:52:05 -0500
Message-ID: <200606270952.05191.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:9237 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1030268AbWF0Ovw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:51:52 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a simple typo from the last set of driver simplifications patches. 
Now TX bytes stats are actually incremented rather than just containing the 
size of the last packet sent.

Signed-off-by: Brent Cook <bcook@bpointsys.com>

--- a/drivers/net/mv643xx_eth.c	2006-05-04 00:51:47.000000000 -0500
+++ b/drivers/net/mv643xx_eth.c	2006-06-27 09:20:58.000000000 -0500
@@ -1211,7 +1218,7 @@
 	spin_lock_irqsave(&mp->lock, flags);
 
 	eth_tx_submit_descs_for_skb(mp, skb);
-	stats->tx_bytes = skb->len;
+	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
