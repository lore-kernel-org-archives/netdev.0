From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v5 4/8] 6lowpan: change tag type to __be16
Date: Thu, 27 Feb 2014 09:06:18 +0100
Message-ID: <1393488382-1250-5-git-send-email-alex.aring@gmail.com>
References: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:62713 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaB0IGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 03:06:46 -0500
Received: by mail-ea0-f170.google.com with SMTP id g15so1602413eak.29
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 00:06:45 -0800 (PST)
In-Reply-To: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 872c8f9..6b7d17f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -68,7 +68,7 @@ static LIST_HEAD(lowpan_devices);
 struct lowpan_dev_info {
 	struct net_device	*real_dev; /* real WPAN device ptr */
 	struct mutex		dev_list_mtx; /* mutex for list ops */
-	unsigned short		fragment_tag;
+	__be16			fragment_tag;
 };
 
 struct lowpan_dev_record {
@@ -424,7 +424,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
 	u16 dgram_offset, dgram_size, payload_length, header_length,
-	    lowpan_size, frag_plen, offset, tag;
+	    lowpan_size, frag_plen, offset;
+	__be16 tag;
 	u8 head[5];
 
 	header_length = skb->mac_len;
-- 
1.9.0
