From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/6] flow_dissector: Include ip_proto in hash computation
Date: Fri, 27 Feb 2015 19:11:45 -0800
Message-ID: <1425093109-1077-3-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:39362 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbB1DMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:12:49 -0500
Received: by iecvy18 with SMTP id vy18so35751384iec.6
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:12:48 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fold ip_proto into dst when computing hash. This provides a more
standard 5-tuple hash.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2c35c02..f73a248 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -276,6 +276,7 @@ static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c)
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 {
 	u32 hash;
+	u32 extra;
 
 	/* get a consistent hash (same value on both flow directions) */
 	if (((__force u32)keys->dst < (__force u32)keys->src) ||
@@ -285,7 +286,8 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 		swap(keys->port16[0], keys->port16[1]);
 	}
 
-	hash = __flow_hash_3words((__force u32)keys->dst,
+	extra = keys->ip_proto;
+	hash = __flow_hash_3words((__force u32)keys->dst ^ extra,
 				  (__force u32)keys->src,
 				  (__force u32)keys->ports);
 	if (!hash)
-- 
2.2.0.rc0.207.ga3a616c
