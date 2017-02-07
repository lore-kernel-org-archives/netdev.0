From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 1/3] net/skbuff: Introduce skb_mac_offset()
Date: Tue,  7 Feb 2017 09:56:06 +0200
Message-ID: <20170207075608.8430-2-amir@vadai.me>
References: <20170207075608.8430-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35138 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752872AbdBGH40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:56:26 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so26663216wmu.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:56:25 -0800 (PST)
In-Reply-To: <20170207075608.8430-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce skb_mac_offset() that could be used to get mac header offset.

Signed-off-by: Amir Vadai <amir@vadai.me>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c6a78e1892b6..a1b73b794a38 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2182,6 +2182,11 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
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
