From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/5] tipc: set skb->protocol in eth_media packet transmission
Date: Wed, 17 Apr 2013 18:18:27 +0200
Message-ID: <1366215509-18500-4-git-send-email-kaber@trash.net>
References: <1366215509-18500-1-git-send-email-kaber@trash.net>
Cc: davem@davemloft.net, allan.stephens@windriver.com,
	netdev@vger.kernel.org, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60739 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab3DQQTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:19:03 -0400
In-Reply-To: <1366215509-18500-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb->protocol field is used by packet classifiers and for AF_PACKET
cooked format, TIPC needs to set it properly.

Fixes packet classification and ethertype of 0x0000 in cooked captures:

Out 20:c9:d0:43:12:d9 ethertype Unknown (0x0000), length 56:
	0x0000:  5b50 0028 0000 30d4 0100 1000 0100 1001  [P.(..0.........
	0x0010:  0000 03e8 0000 0001 20c9 d043 12d9 0000  ...........C....
	0x0020:  0000 0000 0000 0000                      ........

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/tipc/eth_media.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 0648819..120a676 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -111,6 +111,7 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 
 	skb_reset_network_header(clone);
 	clone->dev = dev;
+	clone->protocol = htons(ETH_P_TIPC);
 	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
 			dev->dev_addr, clone->len);
 	dev_queue_xmit(clone);
-- 
1.8.1.4
