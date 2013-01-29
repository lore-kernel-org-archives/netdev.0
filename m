From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 5/5] netfilter ipset: Use ipv6_addr_equal() where
 appropriate.
Date: Wed, 30 Jan 2013 07:49:03 +0900
Message-ID: <510851DF.9010804@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54641 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751775Ab3A2WtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:49:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/netfilter/ipset/ip_set_hash_ip.c        |    2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    4 ++--
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 ++--
 net/netfilter/ipset/ip_set_hash_net.c       |    2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c  |    2 +-
 net/netfilter/ipset/ip_set_hash_netport.c   |    2 +-
 7 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 5c0b785..b7d4cb4 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -234,7 +234,7 @@ hash_ip6_data_equal(const struct hash_ip6_elem *ip1,
 		    const struct hash_ip6_elem *ip2,
 		    u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0;
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6);
 }
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 6283351..d8f77ba 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -284,7 +284,7 @@ hash_ipport6_data_equal(const struct hash_ipport6_elem *ip1,
 			const struct hash_ipport6_elem *ip2,
 			u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
 	       ip1->port == ip2->port &&
 	       ip1->proto == ip2->proto;
 }
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 6a21271..1da1e95 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -294,8 +294,8 @@ hash_ipportip6_data_equal(const struct hash_ipportip6_elem *ip1,
 			  const struct hash_ipportip6_elem *ip2,
 			  u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
-	       ipv6_addr_cmp(&ip1->ip2.in6, &ip2->ip2.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
+	       ipv6_addr_equal(&ip1->ip2.in6, &ip2->ip2.in6) &&
 	       ip1->port == ip2->port &&
 	       ip1->proto == ip2->proto;
 }
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2d5cd4e..f262722 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -388,8 +388,8 @@ hash_ipportnet6_data_equal(const struct hash_ipportnet6_elem *ip1,
 			   const struct hash_ipportnet6_elem *ip2,
 			   u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
-	       ipv6_addr_cmp(&ip1->ip2.in6, &ip2->ip2.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
+	       ipv6_addr_equal(&ip1->ip2.in6, &ip2->ip2.in6) &&
 	       ip1->cidr == ip2->cidr &&
 	       ip1->port == ip2->port &&
 	       ip1->proto == ip2->proto;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 29e94b9..4b677cf 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -286,7 +286,7 @@ hash_net6_data_equal(const struct hash_net6_elem *ip1,
 		     const struct hash_net6_elem *ip2,
 		     u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
 	       ip1->cidr == ip2->cidr;
 }
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 45a1014..6ba985f 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -471,7 +471,7 @@ hash_netiface6_data_equal(const struct hash_netiface6_elem *ip1,
 			  const struct hash_netiface6_elem *ip2,
 			  u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
 	       ip1->cidr == ip2->cidr &&
 	       (++*multi) &&
 	       ip1->physdev == ip2->physdev &&
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 7ef700d..af20c0c 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -350,7 +350,7 @@ hash_netport6_data_equal(const struct hash_netport6_elem *ip1,
 			 const struct hash_netport6_elem *ip2,
 			 u32 *multi)
 {
-	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
+	return ipv6_addr_equal(&ip1->ip.in6, &ip2->ip.in6) &&
 	       ip1->port == ip2->port &&
 	       ip1->proto == ip2->proto &&
 	       ip1->cidr == ip2->cidr;
-- 
1.7.9.5
