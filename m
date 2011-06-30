From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 4/5] ieee802154: free skb buffer if dev isn't running
Date: Thu, 30 Jun 2011 16:37:47 +0400
Message-ID: <1309437468-31021-5-git-send-email-dbaryshkov@gmail.com>
References: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab1F3MiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:16 -0400
Received: by mail-wy0-f174.google.com with SMTP id 8so1510445wyg.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:16 -0700 (PDT)
In-Reply-To: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/af_ieee802154.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 6df6ecf..40e606f 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -302,7 +302,7 @@ static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
 	if (!netif_running(dev))
-		return -ENODEV;
+		goto drop;
 	pr_debug("got frame, type %d, dev %p\n", dev->type, dev);
 #ifdef DEBUG
 	print_hex_dump_bytes("ieee802154_rcv ", DUMP_PREFIX_NONE, skb->data, skb->len);
-- 
1.7.5.4

