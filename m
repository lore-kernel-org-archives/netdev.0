From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 2/8] net/flow_dissector: Make dissector_uses_key() and skb_flow_dissector_target() public
Date: Tue,  1 Mar 2016 16:24:44 +0200
Message-ID: <1456842290-7844-3-git-send-email-amir@vadai.me>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34174 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbcCAOVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:21:39 -0500
Received: by mail-wm0-f67.google.com with SMTP id p65so4362459wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:21:39 -0800 (PST)
In-Reply-To: <1456842290-7844-1-git-send-email-amir@vadai.me>
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
