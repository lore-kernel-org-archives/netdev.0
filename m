From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] netfilter: nf_tables: consolidate Kconfig options
Date: Mon,  9 Mar 2015 18:14:30 +0100
Message-ID: <1425921275-9171-8-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47234 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753743AbbCIRLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:11:11 -0400
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   38 +++++++++++++++++++++-----------------
 net/ipv6/netfilter/Kconfig |   18 +++++++++++-------
 net/netfilter/Kconfig      |   20 +++++---------------
 3 files changed, 37 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 59f883d..fb20f36 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -36,24 +36,16 @@ config NF_CONNTRACK_PROC_COMPAT
 
 	  If unsure, say Y.
 
-config NF_LOG_ARP
-	tristate "ARP packet logging"
-	default m if NETFILTER_ADVANCED=n
-	select NF_LOG_COMMON
-
-config NF_LOG_IPV4
-	tristate "IPv4 packet logging"
-	default m if NETFILTER_ADVANCED=n
-	select NF_LOG_COMMON
+if NF_TABLES
 
 config NF_TABLES_IPV4
-	depends on NF_TABLES
 	tristate "IPv4 nf_tables support"
 	help
 	  This option enables the IPv4 support for nf_tables.
 
+if NF_TABLES_IPV4
+
 config NFT_CHAIN_ROUTE_IPV4
-	depends on NF_TABLES_IPV4
 	tristate "IPv4 nf_tables route chain support"
 	help
 	  This option enables the "route" chain for IPv4 in nf_tables. This
@@ -61,22 +53,34 @@ config NFT_CHAIN_ROUTE_IPV4
 	  fields such as the source, destination, type of service and
 	  the packet mark.
 
-config NF_REJECT_IPV4
-	tristate "IPv4 packet rejection"
-	default m if NETFILTER_ADVANCED=n
-
 config NFT_REJECT_IPV4
-	depends on NF_TABLES_IPV4
 	select NF_REJECT_IPV4
 	default NFT_REJECT
 	tristate
 
+endif # NF_TABLES_IPV4
+
 config NF_TABLES_ARP
-	depends on NF_TABLES
 	tristate "ARP nf_tables support"
 	help
 	  This option enables the ARP support for nf_tables.
 
+endif # NF_TABLES
+
+config NF_LOG_ARP
+	tristate "ARP packet logging"
+	default m if NETFILTER_ADVANCED=n
+	select NF_LOG_COMMON
+
+config NF_LOG_IPV4
+	tristate "IPv4 packet logging"
+	default m if NETFILTER_ADVANCED=n
+	select NF_LOG_COMMON
+
+config NF_REJECT_IPV4
+	tristate "IPv4 packet rejection"
+	default m if NETFILTER_ADVANCED=n
+
 config NF_NAT_IPV4
 	tristate "IPv4 NAT"
 	depends on NF_CONNTRACK_IPV4
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index a069822..ca69983 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -25,14 +25,16 @@ config NF_CONNTRACK_IPV6
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+if NF_TABLES
+
 config NF_TABLES_IPV6
-	depends on NF_TABLES
 	tristate "IPv6 nf_tables support"
 	help
 	  This option enables the IPv6 support for nf_tables.
 
+if NF_TABLES_IPV6
+
 config NFT_CHAIN_ROUTE_IPV6
-	depends on NF_TABLES_IPV6
 	tristate "IPv6 nf_tables route chain support"
 	help
 	  This option enables the "route" chain for IPv6 in nf_tables. This
@@ -40,16 +42,18 @@ config NFT_CHAIN_ROUTE_IPV6
 	  fields such as the source, destination, flowlabel, hop-limit and
 	  the packet mark.
 
-config NF_REJECT_IPV6
-	tristate "IPv6 packet rejection"
-	default m if NETFILTER_ADVANCED=n
-
 config NFT_REJECT_IPV6
-	depends on NF_TABLES_IPV6
 	select NF_REJECT_IPV6
 	default NFT_REJECT
 	tristate
 
+endif # NF_TABLES_IPV6
+endif # NF_TABLES
+
+config NF_REJECT_IPV6
+	tristate "IPv6 packet rejection"
+	default m if NETFILTER_ADVANCED=n
+
 config NF_LOG_IPV6
 	tristate "IPv6 packet logging"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c68c3b4..971cd75 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -438,8 +438,10 @@ config NF_TABLES
 
 	  To compile it as a module, choose M here.
 
+if NF_TABLES
+
 config NF_TABLES_INET
-	depends on NF_TABLES && IPV6
+	depends on IPV6
 	select NF_TABLES_IPV4
 	select NF_TABLES_IPV6
 	tristate "Netfilter nf_tables mixed IPv4/IPv6 tables support"
@@ -447,21 +449,18 @@ config NF_TABLES_INET
 	  This option enables support for a mixed IPv4/IPv6 "inet" table.
 
 config NFT_EXTHDR
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables IPv6 exthdr module"
 	help
 	  This option adds the "exthdr" expression that you can use to match
 	  IPv6 extension headers.
 
 config NFT_META
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables meta module"
 	help
 	  This option adds the "meta" expression that you can use to match and
 	  to set packet metainformation such as the packet mark.
 
 config NFT_CT
-	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
 	help
@@ -469,42 +468,36 @@ config NFT_CT
 	  connection tracking information such as the flow state.
 
 config NFT_RBTREE
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables rbtree set module"
 	help
 	  This option adds the "rbtree" set type (Red Black tree) that is used
 	  to build interval-based sets.
 
 config NFT_HASH
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables hash set module"
 	help
 	  This option adds the "hash" set type that is used to build one-way
 	  mappings between matchings and actions.
 
 config NFT_COUNTER
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables counter module"
 	help
 	  This option adds the "counter" expression that you can use to
 	  include packet and byte counters in a rule.
 
 config NFT_LOG
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables log module"
 	help
 	  This option adds the "log" expression that you can use to log
 	  packets matching some criteria.
 
 config NFT_LIMIT
-	depends on NF_TABLES
 	tristate "Netfilter nf_tables limit module"
 	help
 	  This option adds the "limit" expression that you can use to
 	  ratelimit rule matchings.
 
 config NFT_MASQ
-	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	depends on NF_NAT
 	tristate "Netfilter nf_tables masquerade support"
@@ -513,7 +506,6 @@ config NFT_MASQ
 	  to perform NAT in the masquerade flavour.
 
 config NFT_REDIR
-	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	depends on NF_NAT
 	tristate "Netfilter nf_tables redirect support"
@@ -522,7 +514,6 @@ config NFT_REDIR
 	  to perform NAT in the redirect flavour.
 
 config NFT_NAT
-	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	select NF_NAT
 	tristate "Netfilter nf_tables nat module"
@@ -531,7 +522,6 @@ config NFT_NAT
 	  typical Network Address Translation (NAT) packet transformations.
 
 config NFT_QUEUE
-	depends on NF_TABLES
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_NETLINK_QUEUE
 	tristate "Netfilter nf_tables queue module"
@@ -540,7 +530,6 @@ config NFT_QUEUE
 	  infrastructure (also known as NFQUEUE) from nftables.
 
 config NFT_REJECT
-	depends on NF_TABLES
 	default m if NETFILTER_ADVANCED=n
 	tristate "Netfilter nf_tables reject support"
 	help
@@ -554,7 +543,6 @@ config NFT_REJECT_INET
 	tristate
 
 config NFT_COMPAT
-	depends on NF_TABLES
 	depends on NETFILTER_XTABLES
 	tristate "Netfilter x_tables over nf_tables module"
 	help
@@ -562,6 +550,8 @@ config NFT_COMPAT
 	  x_tables match/target extensions over the nf_tables
 	  framework.
 
+endif # NF_TABLES
+
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	default m if NETFILTER_ADVANCED=n
-- 
1.7.10.4
