From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: fix compilation of the nfnl_cthelper if NF_CONNTRACK is unset
Date: Tue, 19 Jun 2012 05:16:28 +0200
Message-ID: <1340075789-6196-4-git-send-email-pablo@netfilter.org>
References: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53893 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab2FSDRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 23:17:16 -0400
In-Reply-To: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes the compilation of net/netfilter/nfnetlink_cthelper.c
if CONFIG_NF_CONNTRACK is not set.

This patch also moves the definition of the cthelper infrastructure to
the scope of NF_CONNTRACK things.

I have also renamed NETFILTER_NETLINK_CTHELPER by NF_CT_NETLINK_HELPER,
to use similar names to other nf_conntrack_netlink extensions. Better now
that this has been only for two days in David's tree.

Two new dependencies have been added:

* NF_CT_NETLINK
* NETFILTER_NETLINK_QUEUE

Since these infrastructure requires both ctnetlink and nfqueue.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig  |   20 ++++++++++++--------
 net/netfilter/Makefile |    2 +-
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index aae6c62..f1a52ba 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -12,14 +12,6 @@ tristate "Netfilter NFACCT over NFNETLINK interface"
 	  If this option is enabled, the kernel will include support
 	  for extended accounting via NFNETLINK.
 
-config NETFILTER_NETLINK_CTHELPER
-tristate "Netfilter CTHELPER over NFNETLINK interface"
-	depends on NETFILTER_ADVANCED
-	select NETFILTER_NETLINK
-	help
-	  If this option is enabled, the kernel will include support
-	  for user-space connection tracking helpers via NFNETLINK.
-
 config NETFILTER_NETLINK_QUEUE
 	tristate "Netfilter NFQUEUE over NFNETLINK interface"
 	depends on NETFILTER_ADVANCED
@@ -343,6 +335,18 @@ config NF_CT_NETLINK_TIMEOUT
 
 	  If unsure, say `N'.
 
+config NF_CT_NETLINK_HELPER
+	tristate 'Connection tracking helpers in user-space via Netlink'
+	select NETFILTER_NETLINK
+	depends on NF_CT_NETLINK
+	depends on NETFILTER_NETLINK_QUEUE
+	depends on NETFILTER_ADVANCED
+	help
+	  This option enables the user-space connection tracking helpers
+	  infrastructure.
+
+	  If unsure, say `N'.
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2f3bc0f..7cc2019 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -9,7 +9,6 @@ obj-$(CONFIG_NETFILTER) = netfilter.o
 
 obj-$(CONFIG_NETFILTER_NETLINK) += nfnetlink.o
 obj-$(CONFIG_NETFILTER_NETLINK_ACCT) += nfnetlink_acct.o
-obj-$(CONFIG_NETFILTER_NETLINK_CTHELPER) += nfnetlink_cthelper.o
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) += nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 
@@ -25,6 +24,7 @@ obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
 # netlink interface for nf_conntrack
 obj-$(CONFIG_NF_CT_NETLINK) += nf_conntrack_netlink.o
 obj-$(CONFIG_NF_CT_NETLINK_TIMEOUT) += nfnetlink_cttimeout.o
+obj-$(CONFIG_NF_CT_NETLINK_HELPER) += nfnetlink_cthelper.o
 
 # connection tracking helpers
 nf_conntrack_h323-objs := nf_conntrack_h323_main.o nf_conntrack_h323_asn1.o
-- 
1.7.10
