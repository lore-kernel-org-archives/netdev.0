From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 1/2] ieee802154: use standard routine for printing dumps
Date: Thu, 18 Jun 2009 18:16:46 +0400
Message-ID: <1245334607-16046-2-git-send-email-dbaryshkov@gmail.com>
References: <1245334607-16046-1-git-send-email-dbaryshkov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:64086 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbZFRORF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:17:05 -0400
In-Reply-To: <1245334607-16046-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use print_hex_dump_bytes instead of self-written dumping function
for outputting packet dumps.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/af_ieee802154.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 882a927..3bb6bdb 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -39,14 +39,6 @@
 
 #include "af802154.h"
 
-#define DBG_DUMP(data, len) { \
-	int i; \
-	pr_debug("function: %s: data: len %d:\n", __func__, len); \
-	for (i = 0; i < len; i++) {\
-		pr_debug("%02x: %02x\n", i, (data)[i]); \
-	} \
-}
-
 /*
  * Utility function for families
  */
@@ -302,10 +294,12 @@ static struct net_proto_family ieee802154_family_ops = {
 static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
-	DBG_DUMP(skb->data, skb->len);
 	if (!netif_running(dev))
 		return -ENODEV;
 	pr_debug("got frame, type %d, dev %p\n", dev->type, dev);
+#ifdef DEBUG
+	print_hex_dump_bytes("ieee802154_rcv ", DUMP_PREFIX_NONE, skb->data, skb->len);
+#endif
 
 	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
-- 
1.6.3.1

