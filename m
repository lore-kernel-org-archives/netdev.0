From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/5] tipc: correct return value of recv_msg routine
Date: Tue, 24 Sep 2013 04:27:47 -0500
Message-ID: <1380014868-2797-5-git-send-email-jon.maloy@ericsson.com>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.bf1.yahoo.com ([98.139.244.54]:29740 "HELO
	smtp106.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750718Ab3IXJex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 05:34:53 -0400
In-Reply-To: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Currently, rcv_msg() always returns zero on a packet delivery upcall
from net_device.

To make its behavior more compliant with the way this API should be
used, we change this to let it return NET_RX_SUCCESS (which is zero
anyway) when it is able to handle the packet, and NET_RX_DROP otherwise.
The latter does not imply any functional change, it only enables the
driver to keep more accurate statistics about the fate of delivered
packets.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/eth_media.c |    6 +++---
 net/tipc/ib_media.c  |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index c36c938..f80d59f 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -132,18 +132,18 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
-		return 0;
+		return NET_RX_DROP;
 	}
 
 	if (likely(eb_ptr->bearer)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
 			tipc_recv_msg(buf, eb_ptr->bearer);
-			return 0;
+			return NET_RX_SUCCESS;
 		}
 	}
 	kfree_skb(buf);
-	return 0;
+	return NET_RX_DROP;
 }
 
 /**
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 20b1aa4..c139892 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -125,18 +125,18 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
-		return 0;
+		return NET_RX_DROP;
 	}
 
 	if (likely(ib_ptr->bearer)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
 			tipc_recv_msg(buf, ib_ptr->bearer);
-			return 0;
+			return NET_RX_SUCCESS;
 		}
 	}
 	kfree_skb(buf);
-	return 0;
+	return NET_RX_DROP;
 }
 
 /**
-- 
1.7.9.5
