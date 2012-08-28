From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 15/19] netfilter: nf_nat: support IPv6 in amanda NAT helper
Date: Tue, 28 Aug 2012 23:48:55 +0200
Message-ID: <1346190539-9963-16-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59150 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab2H1VtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 17:49:07 -0400
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig               |    5 -----
 net/ipv4/netfilter/Makefile              |    1 -
 net/netfilter/Kconfig                    |    5 +++++
 net/netfilter/Makefile                   |    1 +
 net/netfilter/nf_conntrack_amanda.c      |    3 +--
 net/{ipv4 => }/netfilter/nf_nat_amanda.c |    0
 6 files changed, 7 insertions(+), 8 deletions(-)
 rename net/{ipv4 => }/netfilter/nf_nat_amanda.c (100%)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 8c6c692..52c4a87 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -231,11 +231,6 @@ config NF_NAT_TFTP
 	depends on NF_CONNTRACK && NF_NAT_IPV4
 	default NF_NAT_IPV4 && NF_CONNTRACK_TFTP
 
-config NF_NAT_AMANDA
-	tristate
-	depends on NF_CONNTRACK && NF_NAT_IPV4
-	default NF_NAT_IPV4 && NF_CONNTRACK_AMANDA
-
 config NF_NAT_PPTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT_IPV4
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 4d8a4ad..8baa496 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -20,7 +20,6 @@ obj-$(CONFIG_NF_NAT_IPV4) += nf_nat_ipv4.o
 obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # NAT helpers (nf_conntrack)
-obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 3104494..2eee9f1 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -380,6 +380,11 @@ config NF_NAT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
 	select LIBCRC32C
 
+config NF_NAT_AMANDA
+	tristate
+	depends on NF_CONNTRACK && NF_NAT
+	default NF_NAT && NF_CONNTRACK_AMANDA
+
 config NF_NAT_FTP
 	tristate
 	depends on NF_CONNTRACK && NF_NAT
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 16592b1..7d6e1ea 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # NAT helpers
+obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 
 # transparent proxy support
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index e0212b5..c514fe6 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -155,8 +155,7 @@ static int amanda_help(struct sk_buff *skb,
 				  IPPROTO_TCP, NULL, &port);
 
 		nf_nat_amanda = rcu_dereference(nf_nat_amanda_hook);
-		if (nf_nat_amanda && nf_ct_l3num(ct) == NFPROTO_IPV4 &&
-		    ct->status & IPS_NAT_MASK)
+		if (nf_nat_amanda && ct->status & IPS_NAT_MASK)
 			ret = nf_nat_amanda(skb, ctinfo, protoff,
 					    off - dataoff, len, exp);
 		else if (nf_ct_expect_related(exp) != 0)
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/netfilter/nf_nat_amanda.c
similarity index 100%
rename from net/ipv4/netfilter/nf_nat_amanda.c
rename to net/netfilter/nf_nat_amanda.c
-- 
1.7.1
