From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7] neigh: Create mechanism for generic neigh private
 areas.
Date: Wed, 30 Nov 2011 22:41:31 -0500 (EST)
Message-ID: <20111130.224131.726739875792706779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab1LADld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:33 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fVkX027297
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:32 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The implementation private sits right after the primary_key memory.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 7ae5acf..87c0e5c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -179,6 +179,13 @@ struct neigh_table {
 	struct pneigh_entry	**phash_buckets;
 };
 
+#define NEIGH_PRIV_ALIGN	sizeof(long long)
+
+static inline void *neighbour_priv(const struct neighbour *n)
+{
+	return (char *)n + ALIGN(sizeof(*n) + n->tbl->key_len, NEIGH_PRIV_ALIGN);
+}
+
 /* flags for neigh_update() */
 #define NEIGH_UPDATE_F_OVERRIDE			0x00000001
 #define NEIGH_UPDATE_F_WEAK_OVERRIDE		0x00000002
-- 
1.7.6.4
