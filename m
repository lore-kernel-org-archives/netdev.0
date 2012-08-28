From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 18/19] netfilter: nf_nat: support IPv6 in TFTP NAT helper
Date: Tue, 28 Aug 2012 23:48:58 +0200
Message-ID: <1346190539-9963-19-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59155 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab2H1VtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:10 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig             |    5 -----
 net/ipv4/netfilter/Makefile            |    1 -
 net/netfilter/Kconfig                  |    5 +++++
 net/netfilter/Makefile                 |    1 +
 net/netfilter/nf_conntrack_tftp.c      |    3 +--
 net/{ipv4 => }/netfilter/nf_nat_tftp.c |    0
 6 files changed, 7 insertions(+), 8 deletions(-)
 rename net/{ipv4 => }/netfilter/nf_nat_tftp.c (100%)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 843fe17..131e537 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -221,11 +221,6 @@ config NF_NAT_PROTO_GRE
 	tristate
 	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
-config NF_NAT_TFTP
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_TFTP
-
 config NF_NAT_PPTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 17e649b..b7dd189 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -23,7 +23,6 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
 obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
-obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index cabe4da..052836e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -400,6 +400,11 @@ config NF_NAT_SIP
 	depends on NF_CONNTRACK && NF_NAT
 	default NF_NAT && NF_CONNTRACK_SIP
 
+config NF_NAT_TFTP
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_TFTP
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 0dd7929..403ea81 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
+obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 9363e1c..81fc61c 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -72,8 +72,7 @@ static int tftp_help(struct sk_buff *skb,
 		nf_ct_dump_tuple(&exp->tuple);
 
 		nf_nat_tftp = rcu_dereference(nf_nat_tftp_hook);
-		if (nf_nat_tftp && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-		    ct->status & IPS_NAT_MASK)
+		if (nf_nat_tftp && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_tftp(skb, ctinfo, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/netfilter/nf_nat_tftp.c
similarity index 100%
rename from net/ipv4/netfilter/nf_nat_tftp.c
rename to net/netfilter/nf_nat_tftp.c
-- 
1.7.1
