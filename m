From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/6] net: Add skb_get_hash_perturb
Date: Sun,  1 Mar 2015 14:09:44 -0800
Message-ID: <1425247789-21211-2-git-send-email-therbert@google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:40116 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbbCAWKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 17:10:10 -0500
Received: by igal13 with SMTP id l13so12785955iga.5
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 14:10:09 -0800 (PST)
In-Reply-To: <1425247789-21211-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used to get the skb->hash and then perturb it for a local use.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d898b32..48c1978 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/kmemcheck.h>
 #include <linux/compiler.h>
+#include <linux/jhash.h>
 #include <linux/time.h>
 #include <linux/bug.h>
 #include <linux/cache.h>
@@ -922,6 +923,20 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
+static inline __u32 skb_get_hash_perturb(struct sk_buff *skb,
+					 u32 perturb)
+{
+	u32 hash = skb_get_hash(skb);
+
+	if (likely(hash)) {
+		hash = jhash_1word((__force __u32) hash, perturb);
+		if (unlikely(!hash))
+			hash = 1;
+	}
+
+	return hash;
+}
+
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 {
 	return skb->hash;
-- 
2.2.0.rc0.207.ga3a616c
