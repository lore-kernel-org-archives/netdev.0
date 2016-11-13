From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/39] netfilter: ipset: Headers file cleanup
Date: Sun, 13 Nov 2016 23:25:12 +0100
Message-ID: <1479075933-4491-19-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Group counter helper functions together.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Suggested-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h | 42 +++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 524467f933bf..1ea28e30a6dd 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -334,6 +334,27 @@ ip_set_update_counter(struct ip_set_counter *counter,
 	}
 }
 
+static inline bool
+ip_set_put_counter(struct sk_buff *skb, const struct ip_set_counter *counter)
+{
+	return nla_put_net64(skb, IPSET_ATTR_BYTES,
+			     cpu_to_be64(ip_set_get_bytes(counter)),
+			     IPSET_ATTR_PAD) ||
+	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
+			     cpu_to_be64(ip_set_get_packets(counter)),
+			     IPSET_ATTR_PAD);
+}
+
+static inline void
+ip_set_init_counter(struct ip_set_counter *counter,
+		    const struct ip_set_ext *ext)
+{
+	if (ext->bytes != ULLONG_MAX)
+		atomic64_set(&(counter)->bytes, (long long)(ext->bytes));
+	if (ext->packets != ULLONG_MAX)
+		atomic64_set(&(counter)->packets, (long long)(ext->packets));
+}
+
 static inline void
 ip_set_get_skbinfo(struct ip_set_skbinfo *skbinfo,
 		   const struct ip_set_ext *ext,
@@ -372,27 +393,6 @@ ip_set_init_skbinfo(struct ip_set_skbinfo *skbinfo,
 	skbinfo->skbqueue = ext->skbqueue;
 }
 
-static inline bool
-ip_set_put_counter(struct sk_buff *skb, const struct ip_set_counter *counter)
-{
-	return nla_put_net64(skb, IPSET_ATTR_BYTES,
-			     cpu_to_be64(ip_set_get_bytes(counter)),
-			     IPSET_ATTR_PAD) ||
-	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
-			     cpu_to_be64(ip_set_get_packets(counter)),
-			     IPSET_ATTR_PAD);
-}
-
-static inline void
-ip_set_init_counter(struct ip_set_counter *counter,
-		    const struct ip_set_ext *ext)
-{
-	if (ext->bytes != ULLONG_MAX)
-		atomic64_set(&(counter)->bytes, (long long)(ext->bytes));
-	if (ext->packets != ULLONG_MAX)
-		atomic64_set(&(counter)->packets, (long long)(ext->packets));
-}
-
 /* Netlink CB args */
 enum {
 	IPSET_CB_NET = 0,	/* net namespace */
-- 
2.1.4

