From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 1/3] net/skbuff: Introduce skb_mac_offset()
Date: Thu,  5 Jan 2017 11:54:52 +0200
Message-ID: <20170105095454.32644-2-amir@vadai.me>
References: <20170105095454.32644-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35739 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754451AbdAEJzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 04:55:21 -0500
Received: by mail-wj0-f193.google.com with SMTP id hb5so45339338wjc.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 01:55:12 -0800 (PST)
In-Reply-To: <20170105095454.32644-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce skb_mac_offset() that could be used to get mac header offset.

Signed-off-by: Amir Vadai <amir@vadai.me>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..3d8f81f39c2b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2178,6 +2178,11 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
 	return skb->head + skb->mac_header;
 }
 
+static inline int skb_mac_offset(const struct sk_buff *skb)
+{
+	return skb_mac_header(skb) - skb->data;
+}
+
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
 	return skb->mac_header != (typeof(skb->mac_header))~0U;
-- 
2.11.0
