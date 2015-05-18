From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/21] netfilter: ipset: Check IPSET_ATTR_PORT only once
Date: Mon, 18 May 2015 18:25:11 +0200
Message-ID: <1431966324-4494-9-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

We do not need to check tb[IPSET_ATTR_PORT] != NULL before
retrieving port, as this attribute is known to exist due to
ip_set_attr_netorder() returning true only when attribute
exists and it is in network byte order.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_ipport.c     |   10 ++--------
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   10 ++--------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   10 ++--------
 net/netfilter/ipset/ip_set_hash_netport.c    |   10 ++--------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   10 ++--------
 5 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 5b36a4e..299fab6 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -139,10 +139,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
@@ -309,10 +306,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 6a580e5..cb79466 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -145,10 +145,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
@@ -321,10 +318,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2b90a1d..2c39cae 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -207,10 +207,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		e.cidr = cidr - 1;
 	}
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
@@ -469,10 +466,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	ip6_netmask(&e.ip2, e.cidr + 1);
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 624eb5b..91c901c 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -196,10 +196,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		e.cidr = cidr - 1;
 	}
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
@@ -420,10 +417,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 	ip6_netmask(&e.ip, e.cidr + 1);
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 7eed11b..1233442 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -225,10 +225,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		e.cidr[1] = cidr;
 	}
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
@@ -505,10 +502,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	ip6_netmask(&e.ip[0], e.cidr[0]);
 	ip6_netmask(&e.ip[1], e.cidr[1]);
 
-	if (tb[IPSET_ATTR_PORT])
-		e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
-	else
-		return -IPSET_ERR_PROTOCOL;
+	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		e.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
-- 
1.7.10.4

