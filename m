From: Joe Perches <joe@perches.com>
Subject: [PATCH 23/25] netfilter: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 16:46:21 -0700
Message-ID: <6f7ba321bbfe862cb7244664f2db08c430523ff3.1427759010.git.joe@perches.com>
References: <cover.1427759009.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0057.hostedemail.com ([216.40.44.57]:37861 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932093AbbC3XsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 19:48:13 -0400
In-Reply-To: <cover.1427759009.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/ipt_ah.c                  | 2 +-
 net/netfilter/ipset/ip_set_hash_ip.c         | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipmark.c     | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipport.c     | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipportip.c   | 8 ++++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c  | 8 ++++----
 net/netfilter/ipset/ip_set_hash_net.c        | 8 ++++----
 net/netfilter/ipset/ip_set_hash_netiface.c   | 8 ++++----
 net/netfilter/ipset/ip_set_hash_netport.c    | 8 ++++----
 net/netfilter/ipset/ip_set_hash_netportnet.c | 8 ++++----
 net/netfilter/xt_connlimit.c                 | 2 +-
 net/netfilter/xt_hashlimit.c                 | 2 +-
 net/netfilter/xt_ipcomp.c                    | 2 +-
 13 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 14a2aa8..756c004 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -47,7 +47,7 @@ static bool ah_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 */
 		pr_debug("Dropping evil AH tinygram.\n");
 		par->hotdrop = true;
-		return 0;
+		return false;
 	}
 
 	return spi_match(ahinfo->spis[0], ahinfo->spis[1],
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 76959d7..a7d6262 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -61,10 +61,10 @@ hash_ip4_data_list(struct sk_buff *skb, const struct hash_ip4_elem *e)
 {
 	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, e->ip))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -196,10 +196,10 @@ hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *e)
 {
 	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &e->ip.in6))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 7abf978..327b331 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -63,10 +63,10 @@ hash_ipmark4_data_list(struct sk_buff *skb,
 	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, data->ip) ||
 	    nla_put_net32(skb, IPSET_ATTR_MARK, htonl(data->mark)))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -191,10 +191,10 @@ hash_ipmark6_data_list(struct sk_buff *skb,
 	if (nla_put_ipaddr6(skb, IPSET_ATTR_IP, &data->ip.in6) ||
 	    nla_put_net32(skb, IPSET_ATTR_MARK, htonl(data->mark)))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index dcbcceb..b4748e9 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -69,10 +69,10 @@ hash_ipport4_data_list(struct sk_buff *skb,
 	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
 	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -231,10 +231,10 @@ hash_ipport6_data_list(struct sk_buff *skb,
 	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
 	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 7ef93fc..607461b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -70,10 +70,10 @@ hash_ipportip4_data_list(struct sk_buff *skb,
 	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
 	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -240,10 +240,10 @@ hash_ipportip6_data_list(struct sk_buff *skb,
 	    nla_put_net16(skb, IPSET_ATTR_PORT, data->port) ||
 	    nla_put_u8(skb, IPSET_ATTR_PROTO, data->proto))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index b6012ad..f607ec9 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -114,10 +114,10 @@ hash_ipportnet4_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -367,10 +367,10 @@ hash_ipportnet6_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 6b3ac10..8bb8cd4 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -95,10 +95,10 @@ hash_net4_data_list(struct sk_buff *skb, const struct hash_net4_elem *data)
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -264,10 +264,10 @@ hash_net6_data_list(struct sk_buff *skb, const struct hash_net6_elem *data)
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 758b002..5a37ede 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -192,10 +192,10 @@ hash_netiface4_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -428,10 +428,10 @@ hash_netiface6_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index c0ddb58..65abe45 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -110,10 +110,10 @@ hash_netport4_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -326,10 +326,10 @@ hash_netport6_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index bfaa94c..8c80e84 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -124,10 +124,10 @@ hash_netportnet4_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
@@ -397,10 +397,10 @@ hash_netportnet6_data_list(struct sk_buff *skb,
 	    (flags &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags))))
 		goto nla_put_failure;
-	return 0;
+	return false;
 
 nla_put_failure:
-	return 1;
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 29ba621..548537c 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -92,7 +92,7 @@ static inline bool already_closed(const struct nf_conn *conn)
 		return conn->proto.tcp.state == TCP_CONNTRACK_TIME_WAIT ||
 		       conn->proto.tcp.state == TCP_CONNTRACK_CLOSE;
 	else
-		return 0;
+		return false;
 }
 
 static int
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 1786968..09c3446 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -285,7 +285,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 static bool select_all(const struct xt_hashlimit_htable *ht,
 		       const struct dsthash_ent *he)
 {
-	return 1;
+	return true;
 }
 
 static bool select_gc(const struct xt_hashlimit_htable *ht,
diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
index 89d5310..85b6a9d 100644
--- a/net/netfilter/xt_ipcomp.c
+++ b/net/netfilter/xt_ipcomp.c
@@ -56,7 +56,7 @@ static bool comp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 */
 		pr_debug("Dropping evil IPComp tinygram.\n");
 		par->hotdrop = true;
-		return 0;
+		return false;
 	}
 
 	return spi_match(compinfo->spis[0], compinfo->spis[1],
-- 
2.1.2
