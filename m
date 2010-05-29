From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/3] korina: use netdev_alloc_skb_ip_align() here, too
Date: Sun, 30 May 2010 01:23:35 +0200
Message-ID: <20100529232348.3179F4CD57@orbit.nwl.cc>
References: <1275175416-21267-1-git-send-email-phil@nwl.cc>
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:38227 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754381Ab0E2XXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 19:23:49 -0400
In-Reply-To: <1275175416-21267-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch completes commit 89d71a66c40d629e3b1285def543ab1425558cd5
which missed this spot, as it seems.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/korina.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 13533f9..3e9b6b7 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -765,10 +765,9 @@ static int korina_alloc_ring(struct net_device *dev)
 
 	/* Initialize the receive descriptors */
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
-		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
+		skb = netdev_alloc_skb_ip_align(dev, KORINA_RBSIZE);
 		if (!skb)
 			return -ENOMEM;
-		skb_reserve(skb, 2);
 		lp->rx_skb[i] = skb;
 		lp->rd_ring[i].control = DMA_DESC_IOD |
 				DMA_COUNT(KORINA_RBSIZE);
-- 
1.6.4.4

