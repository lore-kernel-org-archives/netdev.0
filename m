From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 02/10] net/flow_dissector: Make dissector_uses_key() and skb_flow_dissector_target() public
Date: Thu,  3 Mar 2016 16:55:52 +0200
Message-ID: <1457016960-27832-3-git-send-email-amir@vadai.me>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34866 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758033AbcCCOwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:52:03 -0500
Received: by mail-wm0-f68.google.com with SMTP id 1so4482661wmg.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:52:03 -0800 (PST)
In-Reply-To: <1457016960-27832-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used in a following patch to query if a key is being used, and
what it's value in the target object.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/flow_dissector.h | 13 +++++++++++++
 net/core/flow_dissector.c    | 13 -------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8c8548c..d3d60dc 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -184,4 +184,17 @@ static inline bool flow_keys_have_l4(struct flow_keys *keys)
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
 
+static inline bool dissector_uses_key(const struct flow_dissector *flow_dissector,
+				      enum flow_dissector_key_id key_id)
+{
+	return flow_dissector->used_keys & (1 << key_id);
+}
+
+static inline void *skb_flow_dissector_target(struct flow_dissector *flow_dissector,
+					      enum flow_dissector_key_id key_id,
+					      void *target_container)
+{
+	return ((char *)target_container) + flow_dissector->offset[key_id];
+}
+
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 7c7b873..a669dea 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -19,25 +19,12 @@
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
-static bool dissector_uses_key(const struct flow_dissector *flow_dissector,
-			       enum flow_dissector_key_id key_id)
-{
-	return flow_dissector->used_keys & (1 << key_id);
-}
-
 static void dissector_set_key(struct flow_dissector *flow_dissector,
 			      enum flow_dissector_key_id key_id)
 {
 	flow_dissector->used_keys |= (1 << key_id);
 }
 
-static void *skb_flow_dissector_target(struct flow_dissector *flow_dissector,
-				       enum flow_dissector_key_id key_id,
-				       void *target_container)
-{
-	return ((char *) target_container) + flow_dissector->offset[key_id];
-}
-
 void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 			     const struct flow_dissector_key *key,
 			     unsigned int key_count)
-- 
2.7.0
