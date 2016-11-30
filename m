From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 1/3] net/skbuff: Introduce skb_mac_offset()
Date: Wed, 30 Nov 2016 11:09:26 +0200
Message-ID: <20161130090928.14816-2-amir@vadai.me>
References: <20161130090928.14816-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33821 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757262AbcK3JJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:09:50 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so28387161wme.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 01:09:49 -0800 (PST)
In-Reply-To: <20161130090928.14816-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce skb_mac_offset() that could be used to get mac header offset.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c..395eb5111df0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2169,6 +2169,11 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
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
2.10.2
