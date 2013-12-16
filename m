From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 6/6] plip: slight optimization of addr compare
Date: Mon, 16 Dec 2013 16:24:48 +0800
Message-ID: <52AEB8D0.8080505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:23310 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab3LPIY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches add ether_addr_equal_unaligned to test if
possibly unaligned to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
the slightly faster generic routine ether_addr_equal,
otherwise this uses memcmp.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/plip/plip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 7b4ff35..0c26fb9 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	if(*eth->h_dest&1)
 	{
-		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
+		if(ether_addr_equal_unaligned(eth->h_dest,dev->broadcast))
 			skb->pkt_type=PACKET_BROADCAST;
 		else
 			skb->pkt_type=PACKET_MULTICAST;
-- 
1.8.0
