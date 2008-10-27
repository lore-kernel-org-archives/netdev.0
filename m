From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 05/09]IPtablestng/KernelSpace - patch build files
Date: Mon, 27 Oct 2008 08:22:35 +0330 (IRST)
Message-ID: <20081027045235.BB560C6408D@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

define NETFILTER_PKT_TABLES & NETFILTER_PKT_TUPLE

defining NETFILTER_PKT_TABLES for pkt tables and also NETFILTER_PKT_TUPLE for tuple classifier.
also justify the dependencies of NF_IP_TABLES.

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 9a077cb..a936fd9 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -48,6 +48,7 @@ config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
 	default m if NETFILTER_ADVANCED=n
 	select NETFILTER_XTABLES
+	select NETFILTER_PKT_TABLES
 	help
 	  iptables is a general, extensible packet identification framework.
 	  The packet filtering and full NAT (masquerading, port forwarding,
@@ -56,6 +57,18 @@ config IP_NF_IPTABLES
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+# Classifiers
+config IP_NF_CLASSIFIER_TUPLE
+	tristate "Tuple Classifeir"
+	depends on IP_NF_IPTABLES
+	depends on NETFILTER_PKT_TABLES
+	help
+	  The ability to classify packets base on their source and destination
+	  ips very fast. May be used as search algirithm for chains.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+
 # The matches.
 config IP_NF_MATCH_RECENT
 	tristate '"recent" match support'
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 0c7dc78..531425d 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -40,6 +40,9 @@ obj-$(CONFIG_IP_NF_MANGLE) += iptable_mangle.o
 obj-$(CONFIG_NF_NAT) += iptable_nat.o
 obj-$(CONFIG_IP_NF_RAW) += iptable_raw.o
 
+# classifiers
+obj-$(CONFIG_IP_NF_CLASSIFIER_TUPLE) += ipc_tuple.o
+
 # matches
 obj-$(CONFIG_IP_NF_MATCH_ADDRTYPE) += ipt_addrtype.o
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index daf5b88..5a9e25a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -274,6 +274,14 @@ config NETFILTER_XTABLES
 	  This is required if you intend to use any of ip_tables,
 	  ip6_tables or arp_tables.
 
+config NETFILTER_PKT_TABLES
+	tristate "Netfilter packet tables support (required for ip*_tables)"
+	select NETFILTER_XTABLES
+	default m if NETFILTER_ADVANCED=n	
+	help
+	  This is required if you intend to use any of ip_tables.
+
+
 # alphabetically ordered list of targets
 
 config NETFILTER_XT_TARGET_CLASSIFY
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index ea75083..0ad72a4 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
+obj-$(CONFIG_NETFILTER_PKT_TABLES) += pkt_tables.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o

