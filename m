From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/21] netfilter: ipset: Return bool values instead of int
Date: Mon, 18 May 2015 18:25:13 +0200
Message-ID: <1431966324-4494-11-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44029 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932403AbbERQUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:50 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_ip.c         |   10 +++++-----
 net/netfilter/ipset/ip_set_hash_ipmark.c     |    8 ++++----
 net/netfilter/ipset/ip_set_hash_ipport.c     |    8 ++++----
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    8 ++++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    8 ++++----
 net/netfilter/ipset/ip_set_hash_mac.c        |    7 ++++++-
 net/netfilter/ipset/ip_set_hash_net.c        |    8 ++++----
 net/netfilter/ipset/ip_set_hash_netiface.c   |    8 ++++----
 net/netfilter/ipset/ip_set_hash_netport.c    |    8 ++++----
 net/netfilter/ipset/ip_set_hash_netportnet.c |    8 ++++----
 10 files changed, 43 insertions(+), 38 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 1a9ef0c..e90a82a 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -56,15 +56,15 @@ hash_ip4_data_equal(const struct hash_ip4_elem *e1,
 	return e1->ip == e2->ip;
 }
 
-static inline bool
+static bool
 hash_ip4_data_list(struct sk_buff *skb, const struct hash_ip4_elem *e)
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
@@ -198,10 +198,10 @@ hash_ip6_data_list(struct sk_buff *skb, const struct hash_ip6_elem *e)
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
index 4499373..8584284 100644
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
@@ -193,10 +193,10 @@ hash_ipmark6_data_list(struct sk_buff *skb,
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
index 4ae423c..73e4d86 100644
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
@@ -230,10 +230,10 @@ hash_ipport6_data_list(struct sk_buff *skb,
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
index fb921a5..4f8e584 100644
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
@@ -239,10 +239,10 @@ hash_ipportip6_data_list(struct sk_buff *skb,
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
index 4ae9804..4363a18 100644
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
@@ -366,10 +366,10 @@ hash_ipportnet6_data_list(struct sk_buff *skb,
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
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index 2b96234..3614683 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -52,7 +52,12 @@ hash_mac4_data_equal(const struct hash_mac4_elem *e1,
 static inline bool
 hash_mac4_data_list(struct sk_buff *skb, const struct hash_mac4_elem *e)
 {
-	return nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN, e->ether);
+	if (nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN, e->ether))
+		goto nla_put_failure;
+	return false;
+
+nla_put_failure:
+	return true;
 }
 
 static inline void
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 15382e2..2feaed3 100644
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
@@ -266,10 +266,10 @@ hash_net6_data_list(struct sk_buff *skb, const struct hash_net6_elem *data)
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
index 66ac8dd..322b773 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -193,10 +193,10 @@ hash_netiface4_data_list(struct sk_buff *skb,
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
@@ -446,10 +446,10 @@ hash_netiface6_data_list(struct sk_buff *skb,
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
index 91c901c..bd45465 100644
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
@@ -325,10 +325,10 @@ hash_netport6_data_list(struct sk_buff *skb,
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
index 1233442..dd64ba9 100644
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
@@ -399,10 +399,10 @@ hash_netportnet6_data_list(struct sk_buff *skb,
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
-- 
1.7.10.4
