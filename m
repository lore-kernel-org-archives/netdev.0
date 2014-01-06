From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/13] netfilter: add help information to new nf_tables Kconfig options
Date: Mon,  6 Jan 2014 14:46:39 +0100
Message-ID: <1389016002-9116-11-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59559 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733AbaAFNrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:47:01 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   14 ++++++++++++++
 net/ipv6/netfilter/Kconfig |   12 ++++++++++++
 net/netfilter/Kconfig      |   42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 68 insertions(+)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 9d3d69a..81c6910 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -39,19 +39,33 @@ config NF_CONNTRACK_PROC_COMPAT
 config NF_TABLES_IPV4
 	depends on NF_TABLES
 	tristate "IPv4 nf_tables support"
+	help
+	  This option enables the IPv4 support for nf_tables.
 
 config NFT_CHAIN_ROUTE_IPV4
 	depends on NF_TABLES_IPV4
 	tristate "IPv4 nf_tables route chain support"
+	help
+	  This option enables the "route" chain for IPv4 in nf_tables. This
+	  chain type is used to force packet re-routing after mangling header
+	  fields such as the source, destination, type of service and
+	  the packet mark.
 
 config NFT_CHAIN_NAT_IPV4
 	depends on NF_TABLES_IPV4
 	depends on NF_NAT_IPV4 && NFT_NAT
 	tristate "IPv4 nf_tables nat chain support"
+	help
+	  This option enables the "nat" chain for IPv4 in nf_tables. This
+	  chain type is used to perform Network Address Translation (NAT)
+	  packet transformations such as the source, destination address and
+	  source and destination ports.
 
 config NF_TABLES_ARP
 	depends on NF_TABLES
 	tristate "ARP nf_tables support"
+	help
+	  This option enables the ARP support for nf_tables.
 
 config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 7702f9e..35750df 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -28,15 +28,27 @@ config NF_CONNTRACK_IPV6
 config NF_TABLES_IPV6
 	depends on NF_TABLES
 	tristate "IPv6 nf_tables support"
+	help
+	  This option enables the IPv6 support for nf_tables.
 
 config NFT_CHAIN_ROUTE_IPV6
 	depends on NF_TABLES_IPV6
 	tristate "IPv6 nf_tables route chain support"
+	help
+	  This option enables the "route" chain for IPv6 in nf_tables. This
+	  chain type is used to force packet re-routing after mangling header
+	  fields such as the source, destination, flowlabel, hop-limit and
+	  the packet mark.
 
 config NFT_CHAIN_NAT_IPV6
 	depends on NF_TABLES_IPV6
 	depends on NF_NAT_IPV6 && NFT_NAT
 	tristate "IPv6 nf_tables nat chain support"
+	help
+	  This option enables the "nat" chain for IPv6 in nf_tables. This
+	  chain type is used to perform Network Address Translation (NAT)
+	  packet transformations such as the source, destination address and
+	  source and destination ports.
 
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index a1dec61..0609514 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -416,45 +416,83 @@ endif # NF_CONNTRACK
 config NF_TABLES
 	select NETFILTER_NETLINK
 	tristate "Netfilter nf_tables support"
+	help
+	  nftables is the new packet classification framework that intends to
+	  replace the existing {ip,ip6,arp,eb}_tables infrastructure. It
+	  provides a pseudo-state machine with an extensible instruction-set
+	  (also known as expressions) that the userspace 'nft' utility
+	  (http://www.netfilter.org/projects/nftables) uses to build the
+	  rule-set. It also comes with the generic set infrastructure that
+	  allows you to construct mappings between matchings and actions
+	  for performance lookups.
+
+	  To compile it as a module, choose M here.
 
 config NFT_EXTHDR
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables IPv6 exthdr module"
+	help
+	  This option adds the "exthdr" expression that you can use to match
+	  IPv6 extension headers.
 
 config NFT_META
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables meta module"
+	help
+	  This option adds the "meta" expression that you can use to match and
+	  to set packet metainformation such as the packet mark.
 
 config NFT_CT
 	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
+	help
+	  This option adds the "meta" expression that you can use to match
+	  connection tracking information such as the flow state.
 
 config NFT_RBTREE
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables rbtree set module"
+	help
+	  This option adds the "rbtree" set type (Red Black tree) that is used
+	  to build interval-based sets.
 
 config NFT_HASH
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables hash set module"
+	help
+	  This option adds the "hash" set type that is used to build one-way
+	  mappings between matchings and actions.
 
 config NFT_COUNTER
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables counter module"
+	help
+	  This option adds the "counter" expression that you can use to
+	  include packet and byte counters in a rule.
 
 config NFT_LOG
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables log module"
+	help
+	  This option adds the "log" expression that you can use to log
+	  packets matching some criteria.
 
 config NFT_LIMIT
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables limit module"
+	help
+	  This option adds the "limit" expression that you can use to
+	  ratelimit rule matchings.
 
 config NFT_NAT
 	depends on NF_TABLES
 	depends on NF_CONNTRACK
 	depends on NF_NAT
 	tristate "Netfilter nf_tables nat module"
+	help
+	  This option adds the "nat" expression that you can use to perform
+	  typical Network Address Translation (NAT) packet transformations.
 
 config NFT_QUEUE
 	depends on NF_TABLES
@@ -470,6 +508,10 @@ config NFT_REJECT
 	depends on NF_TABLES_IPV6 || !NF_TABLES_IPV6
 	default m if NETFILTER_ADVANCED=n
 	tristate "Netfilter nf_tables reject support"
+	help
+	  This option adds the "reject" expression that you can use to
+	  explicitly deny and notify via TCP reset/ICMP informational errors
+	  unallowed traffic.
 
 config NFT_COMPAT
 	depends on NF_TABLES
-- 
1.7.10.4
