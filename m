From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 04/19] hamradio: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:53:23 +0800
Message-ID: <52CCBDA3.8090302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Joerg Reuter <jreuter@yaina.de>, <linux-hams@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:56609 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbaAHCx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:53:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Joerg Reuter <jreuter@yaina.de>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/hamradio/bpqether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index f91bf0d..d50b23c 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -208,7 +208,7 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	eth = eth_hdr(skb);
 
 	if (!(bpq->acpt_addr[0] & 0x01) &&
-	    memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN))
+	    !ether_addr_equal(eth->h_source, bpq->acpt_addr))
 		goto drop_unlock;
 
 	if (skb_cow(skb, sizeof(struct ethhdr)))
-- 
1.8.0
