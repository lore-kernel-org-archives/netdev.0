From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] 3C509: rx_bytes should not be increased when alloc_skb
 failed
Date: Tue, 20 May 2008 17:13:52 +0800
Message-ID: <48329650.60809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: becker@scyld.com, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51417 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758172AbYETJQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 05:16:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If alloc_skb failed, the recieved packet will be dropped. Do not increase
rx_bytes for dropped packet.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/3c509.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index e6c545f..fe6d841 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1063,7 +1063,6 @@ el3_rx(struct net_device *dev)
 			struct sk_buff *skb;
 
 			skb = dev_alloc_skb(pkt_len+5);
-			dev->stats.rx_bytes += pkt_len;
 			if (el3_debug > 4)
 				printk("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -1078,6 +1077,7 @@ el3_rx(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
+				dev->stats.rx_bytes += pkt_len;
 				dev->stats.rx_packets++;
 				continue;
 			}
-- 
1.5.3.4

