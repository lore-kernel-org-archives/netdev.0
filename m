From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/26] netfilter: make comparision helpers stub functions in ZONES=n case
Date: Wed,  6 Jul 2016 16:23:49 +0200
Message-ID: <1467815048-2240-8-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Those comparisions are useless in case of ZONES=n; all conntracks
will reside in the same zone by definition.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_zones.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 4e32512..bd46926 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -68,22 +68,34 @@ static inline bool nf_ct_zone_matches_dir(const struct nf_conntrack_zone *zone,
 static inline u16 nf_ct_zone_id(const struct nf_conntrack_zone *zone,
 				enum ip_conntrack_dir dir)
 {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
 	return nf_ct_zone_matches_dir(zone, dir) ?
 	       zone->id : NF_CT_DEFAULT_ZONE_ID;
+#else
+	return NF_CT_DEFAULT_ZONE_ID;
+#endif
 }
 
 static inline bool nf_ct_zone_equal(const struct nf_conn *a,
 				    const struct nf_conntrack_zone *b,
 				    enum ip_conntrack_dir dir)
 {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
 	return nf_ct_zone_id(nf_ct_zone(a), dir) ==
 	       nf_ct_zone_id(b, dir);
+#else
+	return true;
+#endif
 }
 
 static inline bool nf_ct_zone_equal_any(const struct nf_conn *a,
 					const struct nf_conntrack_zone *b)
 {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
 	return nf_ct_zone(a)->id == b->id;
+#else
+	return true;
+#endif
 }
 #endif /* IS_ENABLED(CONFIG_NF_CONNTRACK) */
 #endif /* _NF_CONNTRACK_ZONES_H */
-- 
2.1.4

