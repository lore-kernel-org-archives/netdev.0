From: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Subject: [PATCH] net: pktgen: Observe needed_headroom of the device
Date: Wed, 29 Jul 2015 12:45:58 +0300
Message-ID: <1438163158-12554-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:42201
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750854AbbG2Jq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 05:46:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate enough space so as not to force the outgoing net device to do
skb_realloc_headroom().

Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
---
 net/core/pktgen.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1ebdf1c..5961da6 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2279,7 +2279,7 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
 {
-	pkt_dev->pkt_overhead = 0;
+	pkt_dev->pkt_overhead = LL_RESERVED_SPACE(pkt_dev->odev);
 	pkt_dev->pkt_overhead += pkt_dev->nr_labels*sizeof(u32);
 	pkt_dev->pkt_overhead += VLAN_TAG_SIZE(pkt_dev);
 	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
@@ -2788,6 +2788,7 @@ static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
 	} else {
 		 skb = __netdev_alloc_skb(dev, size, GFP_NOWAIT);
 	}
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
 	return skb;
 }
-- 
1.8.3.1
