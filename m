From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2 1/4] sk_buff: introduce pskb_network_may_pull()
Date: Wed,  4 Aug 2010 22:43:44 +0800
Message-ID: <1280933024-12132-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:62883 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab0HDOoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 10:44:14 -0400
Received: by pxi14 with SMTP id 14so2013956pxi.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 07:44:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/skbuff.h |    5 +++++
 1 file changed, 5 insertions(+)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d20d9e7..77eb60d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1379,6 +1379,11 @@ static inline int skb_network_offset(const struct sk_buff *skb)
 	return skb_network_header(skb) - skb->data;
 }
 
+static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
+{
+	return pskb_may_pull(skb, skb_network_offset(skb) + len);
+}
+
 /*
  * CPUs often take a performance hit when accessing unaligned memory
  * locations. The actual performance hit varies, it can be small if the
