From: kaber@trash.net
Subject: [PATCH 18/18] netfilter: nf_nat: support IPv6 in amanda NAT helper
Date: Thu, 24 Nov 2011 17:57:29 +0100
Message-ID: <1322153850-10533-19-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47972 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720Ab1KXQ5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:40 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

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
index 1b043a5..1c6917a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -229,11 +229,6 @@ config NF_NAT_TFTP
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
index 0fa8715..b365cf2 100644
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
index 1782da9..353b160 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -321,6 +321,11 @@ config NF_NAT_PROTO_SCTP
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
index a747580..a28e44d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # NAT helpers
+obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
 
 # transparent proxy support
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index dab3913..909c54d 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -156,8 +156,7 @@ static int amanda_help(struct sk_buff *skb,
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
