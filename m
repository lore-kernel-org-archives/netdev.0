From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 1/9] net/flow_dissector: Make dissector_uses_key() and skb_flow_dissector_target() public
Date: Mon,  1 Feb 2016 08:34:37 +0000
Message-ID: <1454315685-32202-2-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32827 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751839AbcBAIgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:36:11 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used in a following patch.

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
index d79699c..db0aa1c 100644
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
