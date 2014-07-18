From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/18] netfilter: fix several Kconfig problems in NF_LOG_*
Date: Fri, 18 Jul 2014 13:01:07 +0200
Message-ID: <1405681272-4994-14-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46608 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761467AbaGRLBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 07:01:25 -0400
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

warning: (NETFILTER_XT_TARGET_LOG) selects NF_LOG_IPV6 which has unmet direct dependencies (NET && INET && IPV6 && NETFILTER && IP6_NF_IPTABLES && NETFILTER_ADVANCED)
warning: (NF_LOG_IPV4 && NF_LOG_IPV6) selects NF_LOG_COMMON which has unmet direct dependencies (NET && INET && NETFILTER && NF_CONNTRACK)

Fixes: 83e96d4 ("netfilter: log: split family specific code to nf_log_{ip,ip6,common}.c files")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |   20 ++++++++++----------
 net/ipv6/netfilter/Kconfig |   10 +++++-----
 net/netfilter/Kconfig      |   10 ++++------
 3 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 12e6057..fb17312 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -36,6 +36,16 @@ config NF_CONNTRACK_PROC_COMPAT
 
 	  If unsure, say Y.
 
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
 config NF_TABLES_IPV4
 	depends on NF_TABLES
 	tristate "IPv4 nf_tables support"
@@ -159,16 +169,6 @@ config IP_NF_TARGET_SYNPROXY
 
 	  To compile it as a module, choose M here. If unsure, say N.
 
-config NF_LOG_ARP
-	tristate "ARP packet logging"
-	default m if NETFILTER_ADVANCED=n
-	select NF_LOG_INET
-
-config NF_LOG_IPV4
-	tristate "IPv4 packet logging"
-	default m if NETFILTER_ADVANCED=n
-	select NF_LOG_COMMON
-
 # NAT + specific targets: nf_conntrack
 config NF_NAT_IPV4
 	tristate "IPv4 NAT"
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 1537130..ac93df1 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -55,6 +55,11 @@ config NFT_REJECT_IPV6
 	default NFT_REJECT
 	tristate
 
+config NF_LOG_IPV6
+	tristate "IPv6 packet logging"
+	depends on NETFILTER_ADVANCED
+	select NF_LOG_COMMON
+
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
 	depends on INET && IPV6
@@ -227,11 +232,6 @@ config IP6_NF_SECURITY
 
          If unsure, say N.
 
-config NF_LOG_IPV6
-	tristate "IPv6 packet logging"
-	depends on NETFILTER_ADVANCED
-	select NF_LOG_COMMON
-
 config NF_NAT_IPV6
 	tristate "IPv6 NAT"
 	depends on NF_CONNTRACK_IPV6
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f17b273..ad751fe 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -46,6 +46,9 @@ config NF_CONNTRACK
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NF_LOG_COMMON
+	tristate
+
 if NF_CONNTRACK
 
 config NF_CONNTRACK_MARK
@@ -359,9 +362,6 @@ config NETFILTER_NETLINK_QUEUE_CT
 	  If this option is enabled, NFQUEUE can include Connection Tracking
 	  information together with the packet is the enqueued via NFNETLINK.
 
-config NF_LOG_COMMON
-	tristate
-
 config NF_NAT
 	tristate
 
@@ -747,9 +747,7 @@ config NETFILTER_XT_TARGET_LED
 
 config NETFILTER_XT_TARGET_LOG
 	tristate "LOG target support"
-	select NF_LOG
-	select NF_LOG_IPV4
-	select NF_LOG_IPV6
+	depends on NF_LOG_IPV4 && NF_LOG_IPV6
 	default m if NETFILTER_ADVANCED=n
 	help
 	  This option adds a `LOG' target, which allows you to create rules in
-- 
1.7.10.4
