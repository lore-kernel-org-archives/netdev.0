From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/34] netfilter: masquerading needs to be independent of x_tables in Kconfig
Date: Mon, 29 Sep 2014 14:38:53 +0200
Message-ID: <1411994363-8451-5-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34126 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104AbaI2Mic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:32 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users are starting to test nf_tables with no x_tables support. Therefore,
masquerading needs to be indenpendent of it from Kconfig.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   27 +++++++++++++++------------
 net/ipv6/netfilter/Kconfig |   27 +++++++++++++++------------
 2 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index eb6995f..345242a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -93,6 +93,21 @@ config NFT_CHAIN_NAT_IPV4
 	  packet transformations such as the source, destination address and
 	  source and destination ports.
 
+config NF_NAT_MASQUERADE_IPV4
+	tristate "IPv4 masquerade support"
+	help
+	  This is the kernel functionality to provide NAT in the masquerade
+	  flavour (automatic source address selection).
+
+config NFT_MASQ_IPV4
+	tristate "IPv4 masquerading support for nf_tables"
+	depends on NF_TABLES_IPV4
+	depends on NFT_MASQ
+	select NF_NAT_MASQUERADE_IPV4
+	help
+	  This is the expression that provides IPv4 masquerading support for
+	  nf_tables.
+
 config NF_NAT_SNMP_BASIC
 	tristate "Basic SNMP-ALG support"
 	depends on NF_CONNTRACK_SNMP
@@ -231,18 +246,6 @@ config IP_NF_NAT
 
 if IP_NF_NAT
 
-config NF_NAT_MASQUERADE_IPV4
-	tristate "IPv4 masquerade support"
-	help
-	This is the kernel functionality to provide NAT in the masquerade
-	flavour (automatic source address selection).
-
-config NFT_MASQ_IPV4
-	tristate "IPv4 masquerading support for nf_tables"
-	depends on NF_TABLES_IPV4
-	depends on NFT_MASQ
-	select NF_NAT_MASQUERADE_IPV4
-
 config IP_NF_TARGET_MASQUERADE
 	tristate "MASQUERADE target support"
 	select NF_NAT_MASQUERADE_IPV4
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index e854062..bb1a40d 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -71,6 +71,21 @@ config NFT_CHAIN_NAT_IPV6
 	  packet transformations such as the source, destination address and
 	  source and destination ports.
 
+config NF_NAT_MASQUERADE_IPV6
+	tristate "IPv6 masquerade support"
+	help
+	  This is the kernel functionality to provide NAT in the masquerade
+	  flavour (automatic source address selection) for IPv6.
+
+config NFT_MASQ_IPV6
+	tristate "IPv6 masquerade support for nf_tables"
+	depends on NF_TABLES_IPV6
+	depends on NFT_MASQ
+	select NF_NAT_MASQUERADE_IPV6
+	help
+	  This is the expression that provides IPv4 masquerading support for
+	  nf_tables.
+
 endif # NF_NAT_IPV6
 
 config IP6_NF_IPTABLES
@@ -261,18 +276,6 @@ config IP6_NF_NAT
 
 if IP6_NF_NAT
 
-config NF_NAT_MASQUERADE_IPV6
-	tristate "IPv6 masquerade support"
-	help
-	 This is the kernel functionality to provide NAT in the masquerade
-	 flavour (automatic source address selection) for IPv6.
-
-config NFT_MASQ_IPV6
-	tristate "IPv6 masquerade support for nf_tables"
-	depends on NF_TABLES_IPV6
-	depends on NFT_MASQ
-	select NF_NAT_MASQUERADE_IPV6
-
 config IP6_NF_TARGET_MASQUERADE
 	tristate "MASQUERADE target support"
 	select NF_NAT_MASQUERADE_IPV6
-- 
1.7.10.4
