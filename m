From: Stefan Roese <sr@denx.de>
Subject: [PATCH v2] ibm_newemac: Fixes entry of short packets
Date: Tue,  1 Jul 2008 10:58:19 +0200
Message-ID: <1214902699-10534-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:53453 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbYGAI60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 04:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Narayanan <sathyan@teamf1.com>

Short packets has to be discarded by the driver. So this patch addresses the
issue of discarding the short packets of size lesser then ethernet header
size.

Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index ca63fa0..babc79a 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1636,6 +1636,12 @@ static int emac_poll_rx(void *param, int budget)
 			goto next;
 		}
 
+		if (len < ETH_HLEN) {
+			++dev->estats.rx_dropped_stack;
+			emac_recycle_rx_skb(dev, slot, len);
+			goto next;
+		}
+
 		if (len && len < EMAC_RX_COPY_THRESH) {
 			struct sk_buff *copy_skb =
 			    alloc_skb(len + EMAC_RX_SKB_HEADROOM + 2, GFP_ATOMIC);
-- 
1.5.6.1

