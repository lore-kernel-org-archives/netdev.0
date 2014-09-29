From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/34] netfilter: NFT_CHAIN_NAT_IPV* is independent of NFT_NAT
Date: Mon, 29 Sep 2014 14:38:52 +0200
Message-ID: <1411994363-8451-4-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have masquerading support in nf_tables, the NAT chain can
be use with it, not only for SNAT/DNAT. So make this chain type
independent of it.

While at it, move it inside the scope of 'if NF_NAT_IPV*' to simplify
dependencies.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   19 +++++++++----------
 net/ipv6/netfilter/Kconfig |   23 +++++++++++++----------
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index d189c52..eb6995f 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -61,16 +61,6 @@ config NFT_CHAIN_ROUTE_IPV4
 	  fields such as the source, destination, type of service and
 	  the packet mark.
 
-config NFT_CHAIN_NAT_IPV4
-	depends on NF_TABLES_IPV4
-	depends on NF_NAT_IPV4 && NFT_NAT
-	tristate "IPv4 nf_tables nat chain support"
-	help
-	  This option enables the "nat" chain for IPv4 in nf_tables. This
-	  chain type is used to perform Network Address Translation (NAT)
-	  packet transformations such as the source, destination address and
-	  source and destination ports.
-
 config NFT_REJECT_IPV4
 	depends on NF_TABLES_IPV4
 	default NFT_REJECT
@@ -94,6 +84,15 @@ config NF_NAT_IPV4
 
 if NF_NAT_IPV4
 
+config NFT_CHAIN_NAT_IPV4
+	depends on NF_TABLES_IPV4
+	tristate "IPv4 nf_tables nat chain support"
+	help
+	  This option enables the "nat" chain for IPv4 in nf_tables. This
+	  chain type is used to perform Network Address Translation (NAT)
+	  packet transformations such as the source, destination address and
+	  source and destination ports.
+
 config NF_NAT_SNMP_BASIC
 	tristate "Basic SNMP-ALG support"
 	depends on NF_CONNTRACK_SNMP
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index a8f2530..e854062 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -40,16 +40,6 @@ config NFT_CHAIN_ROUTE_IPV6
 	  fields such as the source, destination, flowlabel, hop-limit and
 	  the packet mark.
 
-config NFT_CHAIN_NAT_IPV6
-	depends on NF_TABLES_IPV6
-	depends on NF_NAT_IPV6 && NFT_NAT
-	tristate "IPv6 nf_tables nat chain support"
-	help
-	  This option enables the "nat" chain for IPv6 in nf_tables. This
-	  chain type is used to perform Network Address Translation (NAT)
-	  packet transformations such as the source, destination address and
-	  source and destination ports.
-
 config NFT_REJECT_IPV6
 	depends on NF_TABLES_IPV6
 	default NFT_REJECT
@@ -70,6 +60,19 @@ config NF_NAT_IPV6
 	  forms of full Network Address Port Translation. This can be
 	  controlled by iptables or nft.
 
+if NF_NAT_IPV6
+
+config NFT_CHAIN_NAT_IPV6
+	depends on NF_TABLES_IPV6
+	tristate "IPv6 nf_tables nat chain support"
+	help
+	  This option enables the "nat" chain for IPv6 in nf_tables. This
+	  chain type is used to perform Network Address Translation (NAT)
+	  packet transformations such as the source, destination address and
+	  source and destination ports.
+
+endif # NF_NAT_IPV6
+
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
 	depends on INET && IPV6
-- 
1.7.10.4

