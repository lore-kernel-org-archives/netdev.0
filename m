From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/15] batman-adv: use the const qualifier in hash functions
Date: Mon, 14 Jan 2013 09:41:17 +1000
Message-ID: <1358120480-25960-13-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49900 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab3AMXnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:18 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The data argument in each hash function should carry the
"const" qualifier as it is never modified.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 net/batman-adv/hash.h                  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 724adf0..5e834c1 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -57,7 +57,7 @@ static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 static inline uint32_t batadv_choose_backbone_gw(const void *data,
 						 uint32_t size)
 {
-	struct batadv_claim *claim = (struct batadv_claim *)data;
+	const struct batadv_claim *claim = (struct batadv_claim *)data;
 	uint32_t hash = 0;
 
 	hash = batadv_hash_bytes(hash, &claim->addr, sizeof(claim->addr));
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index e053339..ea02148 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -89,7 +89,7 @@ static inline void batadv_hash_delete(struct batadv_hashtable *hash,
  *
  *	Returns the new hash value.
  */
-static inline uint32_t batadv_hash_bytes(uint32_t hash, void *data,
+static inline uint32_t batadv_hash_bytes(uint32_t hash, const void *data,
 					 uint32_t size)
 {
 	const unsigned char *key = data;
-- 
1.8.0.2
