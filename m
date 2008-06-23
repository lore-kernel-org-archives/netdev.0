From: Stefan Roese <sr@denx.de>
Subject: [PATCH] ibm_newemac: Fixes entry of short packets
Date: Mon, 23 Jun 2008 14:55:05 +0200
Message-ID: <1214225705-25850-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56104 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbYFWMzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 08:55:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Narayanan <sathyan@teamf1.com>

Short packets has to be discarded by the driver. So this patch addresses the
issue of discarding the short packets of size lesser then ethernet header
size.

Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 6dfc2c9..aa407b2 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1652,6 +1652,13 @@ static int emac_poll_rx(void *param, int budget)
 
 		skb_put(skb, len);
 	push_packet:
+		if (skb->len < ETH_HLEN) {
+			dev_kfree_skb(skb);
+			printk(KERN_WARNING "%s: short packets dropped\n",
+			       dev->ndev->name);
+			++dev->estats.rx_dropped_stack;
+			goto next;
+		}
 		skb->dev = dev->ndev;
 		skb->protocol = eth_type_trans(skb, dev->ndev);
 		emac_rx_csum(dev, skb, ctrl);
-- 
1.5.6

