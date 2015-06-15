From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/32] netfilter: ipset: Make sure we always return line number on batch
Date: Mon, 15 Jun 2015 23:26:14 +0200
Message-ID: <1434403589-24796-18-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

Even if we return with generic IPSET_ERR_PROTOCOL it is good idea
to return line number if we called in batch mode.

Moreover we are not always exiting with IPSET_ERR_PROTOCOL. For
example hash:ip,port,net may return IPSET_ERR_HASH_RANGE_UNSUPPORTED
or IPSET_ERR_INVALID_CIDR.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    6 +++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    6 +++---
 net/netfilter/ipset/ip_set_bitmap_port.c     |    6 +++---
 net/netfilter/ipset/ip_set_hash_ip.c         |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_ipport.c     |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_mac.c        |    6 +++---
 net/netfilter/ipset/ip_set_hash_net.c        |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netiface.c   |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netnet.c     |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netport.c    |   12 ++++++------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   12 ++++++------
 net/netfilter/ipset/ip_set_list_set.c        |    6 +++---
 15 files changed, 75 insertions(+), 75 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 212005e..7af99c3 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -138,12 +138,12 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP]))
-		return -IPSET_ERR_PROTOCOL;
-
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	if (unlikely(!tb[IPSET_ATTR_IP]))
+		return -IPSET_ERR_PROTOCOL;
+
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 0648e74..7733422 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -239,12 +239,12 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip = 0;
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP]))
-		return -IPSET_ERR_PROTOCOL;
-
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	if (unlikely(!tb[IPSET_ATTR_IP]))
+		return -IPSET_ERR_PROTOCOL;
+
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 10ed264..ec3bda1 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -136,13 +136,13 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 	u16 port_to;
 	int ret = 0;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	port = ip_set_get_h16(tb[IPSET_ATTR_PORT]);
 	if (port < map->first_port || port > map->last_port)
 		return -IPSET_ERR_BITMAP_RANGE;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 2b08b1b..2bbadcc 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -108,12 +108,12 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip = 0, ip_to = 0, hosts;
 	int ret = 0;
 
-	if (unlikely(!tb[IPSET_ATTR_IP]))
-		return -IPSET_ERR_PROTOCOL;
-
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	if (unlikely(!tb[IPSET_ATTR_IP]))
+		return -IPSET_ERR_PROTOCOL;
+
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -240,6 +240,9 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP]))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
@@ -251,9 +254,6 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 68fe40c..3aafb36 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -108,13 +108,13 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip, ip_to = 0;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
@@ -234,6 +234,9 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_MARK)))
 		return -IPSET_ERR_PROTOCOL;
@@ -246,9 +249,6 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 9f03639..4db1270 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -116,14 +116,14 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	bool with_ports = false;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
@@ -273,6 +273,9 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	bool with_ports = false;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
@@ -286,9 +289,6 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index aa0966b..c01bf68 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -119,14 +119,14 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	bool with_ports = false;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
@@ -284,6 +284,9 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	bool with_ports = false;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO)))
@@ -297,9 +300,6 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index f3c6256..e38a029 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -173,15 +173,15 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -420,6 +420,9 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -434,9 +437,6 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index 0d49519..8981c8b 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -107,12 +107,12 @@ hash_mac4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
-	if (unlikely(!tb[IPSET_ATTR_ETHER]))
-		return -IPSET_ERR_PROTOCOL;
-
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	if (unlikely(!tb[IPSET_ATTR_ETHER]))
+		return -IPSET_ERR_PROTOCOL;
+
 	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 5eb334d..2988ec5 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -146,13 +146,13 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u32 ip = 0, ip_to = 0, last;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -312,15 +312,15 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 5eef6f3..c80588c 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -293,14 +293,14 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	char iface[IFNAMSIZ];
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -523,6 +523,9 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	char iface[IFNAMSIZ];
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !tb[IPSET_ATTR_IFACE] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
@@ -530,9 +533,6 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 775b1b0..2e6a1ae 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -167,14 +167,14 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr, cidr2;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -392,6 +392,9 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
@@ -399,9 +402,6 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 0eb73da..7a6448c 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -166,15 +166,15 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -378,6 +378,9 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -386,9 +389,6 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index c3634ad..7ad9a77 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -183,6 +183,9 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr, cidr2;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
@@ -190,9 +193,6 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
@@ -453,6 +453,9 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	bool with_ports = false;
 	int ret;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
@@ -462,9 +465,6 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_IP2_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_ipaddr6(tb[IPSET_ATTR_IP], &e.ip[0]);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 7d1377d..107ea6c 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -383,13 +383,13 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct ip_set *s;
 	int ret = 0;
 
+	if (tb[IPSET_ATTR_LINENO])
+		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
+
 	if (unlikely(!tb[IPSET_ATTR_NAME] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (tb[IPSET_ATTR_LINENO])
-		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
-
 	ret = ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
-- 
1.7.10.4

