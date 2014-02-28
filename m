From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v6 1/8] 6lowpan: add frag information struct
Date: Fri, 28 Feb 2014 07:32:43 +0100
Message-ID: <1393569170-25722-2-git-send-email-alex.aring@gmail.com>
References: <1393569170-25722-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:52913 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbaB1GdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 01:33:00 -0500
Received: by mail-ee0-f44.google.com with SMTP id d49so1941763eek.17
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 22:32:59 -0800 (PST)
In-Reply-To: <1393569170-25722-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a 6lowpan fragmentation struct into cb of skb which
is necessary to hold fragmentation information.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/ieee802154_netdev.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 8196d5d..97b2e34 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -29,6 +29,12 @@
 
 #include <net/af_ieee802154.h>
 
+struct ieee802154_frag_info {
+	__be16 d_tag;
+	u16 d_size;
+	u8 d_offset;
+};
+
 /*
  * A control block of skb passed between the ARPHRD_IEEE802154 device
  * and other stack parts.
@@ -39,6 +45,7 @@ struct ieee802154_mac_cb {
 	struct ieee802154_addr da;
 	u8 flags;
 	u8 seq;
+	struct ieee802154_frag_info frag_info;
 };
 
 static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
-- 
1.9.0
