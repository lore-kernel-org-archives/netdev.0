From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] dl2k: nulify fraginfo after unmap
Date: Wed, 26 Jan 2011 11:45:42 +0100
Message-ID: <20110126104521.GA2431@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159Ab1AZKpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 05:45:44 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0QAjicY032104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 05:45:44 -0500
Received: from localhost (dhcp-1-240.brq.redhat.com [10.34.1.240])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0QAjhFg026677
	for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 05:45:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch fixes: "DMA-API: device driver tries to free an invalid DMA
memory address" warning reported here:
https://bugzilla.redhat.com/show_bug.cgi?id=639824

Reported-by: Frantisek Hanzlik <franta@hanzlici.cz>
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/dl2k.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index e1a8216..c05db60 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1753,8 +1753,6 @@ rio_close (struct net_device *dev)
 
 	/* Free all the skbuffs in the queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		np->rx_ring[i].status = 0;
-		np->rx_ring[i].fraginfo = 0;
 		skb = np->rx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pdev,
@@ -1763,6 +1761,8 @@ rio_close (struct net_device *dev)
 			dev_kfree_skb (skb);
 			np->rx_skbuff[i] = NULL;
 		}
+		np->rx_ring[i].status = 0;
+		np->rx_ring[i].fraginfo = 0;
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		skb = np->tx_skbuff[i];
-- 
1.7.3.4

