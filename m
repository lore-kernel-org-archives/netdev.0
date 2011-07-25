From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 1/7] neigh: Create mechanism for generic neigh private
 areas.
Date: Mon, 25 Jul 2011 03:01:17 -0700 (PDT)
Message-ID: <20110725.030117.316830174679013084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


The implementation private sits right after the primary_key memory.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/neighbour.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4ba8521..8ff9143 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -178,6 +178,13 @@ struct neigh_table {
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
1.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
