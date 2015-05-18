From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/21] netfilter: ipset: Return ipset error instead of bool
Date: Mon, 18 May 2015 18:25:10 +0200
Message-ID: <1431966324-4494-8-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44018 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932373AbbERQUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:48 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

Statement ret = func1() || func2() returns 0 when both func1()
and func2() return 0, or 1 if func1() or func2() returns non-zero.

However in our case func1() and func2() returns error code on
failure, so it seems good to propagate such error codes, rather
than returning 1 in case of failure.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    7 +++++--
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    7 +++++--
 net/netfilter/ipset/ip_set_hash_ip.c         |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_ipport.c     |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_net.c        |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_netiface.c   |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_netnet.c     |   24 ++++++++++++++++++------
 net/netfilter/ipset/ip_set_hash_netport.c    |   14 ++++++++++----
 net/netfilter/ipset/ip_set_hash_netportnet.c |   24 ++++++++++++++++++------
 12 files changed, 126 insertions(+), 48 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 55b083e..306a1bf 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -149,8 +149,11 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 8610474..c5f6a06 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -250,8 +250,11 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index d21d1e6..1c469df 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -120,8 +120,11 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -258,8 +261,11 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index e408bcf..82ef5b3 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -122,8 +122,11 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -255,8 +258,11 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index c4383ad..5b36a4e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -131,8 +131,11 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -298,8 +301,11 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index c48ff45..6a580e5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -133,8 +133,11 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -306,8 +309,11 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index adc3f76..2b90a1d 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -188,8 +188,11 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -445,8 +448,11 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 1abfe74..15382e2 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -159,8 +159,11 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -330,8 +333,11 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 0ba6c58..66ac8dd 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -307,8 +307,11 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -543,8 +546,11 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 9c6da0c..f065024 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -181,9 +181,15 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -408,9 +414,15 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]) ||
-	      ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip[1]) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip[1]);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index f77afd4..624eb5b 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -181,8 +181,11 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -401,8 +404,11 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 69e544f..7eed11b 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -199,9 +199,15 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
-	      ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
@@ -474,9 +480,15 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]) ||
-	      ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip[1]) ||
-	      ip_set_get_extensions(set, tb, &ext);
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP2], &e.ip[1]);
+	if (ret)
+		return ret;
+
+	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-- 
1.7.10.4
