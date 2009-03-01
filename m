From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: replace uses of __constant_{endian}
Date: Sun,  1 Mar 2009 01:42:53 -0800
Message-ID: <1235900574-15319-7-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-2-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-3-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-4-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-5-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-6-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org, Harvey Harrison <harvey.harrison@gmail.com>
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:33371 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753355AbZCAJm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 04:42:58 -0500
In-Reply-To: <1235900574-15319-6-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Base versions handle constant folding now.

Edited by Inaky to fix conflicts due to changes in netdev.c

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 2bdd0cd..a98eb4b 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -402,13 +402,13 @@ void i2400m_tx_timeout(struct net_device *net_dev)
  */
 static
 void i2400m_rx_fake_eth_header(struct net_device *net_dev,
-			       void *_eth_hdr, int protocol)
+			       void *_eth_hdr, __be16 protocol)
 {
 	struct ethhdr *eth_hdr = _eth_hdr;
 
 	memcpy(eth_hdr->h_dest, net_dev->dev_addr, sizeof(eth_hdr->h_dest));
 	memset(eth_hdr->h_source, 0, sizeof(eth_hdr->h_dest));
-	eth_hdr->h_proto = cpu_to_be16(protocol);
+	eth_hdr->h_proto = protocol;
 }
 
 
@@ -474,7 +474,8 @@ void i2400m_net_rx(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		memcpy(skb_put(skb, buf_len), buf, buf_len);
 	}
 	i2400m_rx_fake_eth_header(i2400m->wimax_dev.net_dev,
-				  skb->data - ETH_HLEN, ETH_P_IP);
+				  skb->data - ETH_HLEN,
+				  cpu_to_be16(ETH_P_IP));
 	skb_set_mac_header(skb, -ETH_HLEN);
 	skb->dev = i2400m->wimax_dev.net_dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -526,7 +527,8 @@ void i2400m_net_erx(struct i2400m *i2400m, struct sk_buff *skb,
 	case I2400M_CS_IPV4:
 		protocol = ETH_P_IP;
 		i2400m_rx_fake_eth_header(i2400m->wimax_dev.net_dev,
-					  skb->data - ETH_HLEN, ETH_P_IP);
+					  skb->data - ETH_HLEN,
+					  cpu_to_be16(ETH_P_IP));
 		skb_set_mac_header(skb, -ETH_HLEN);
 		skb->dev = i2400m->wimax_dev.net_dev;
 		skb->protocol = htons(ETH_P_IP);
-- 
1.5.6.5

