From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [net-2.6.22] [IPV4]: Fix build without procfs.
Date: Wed, 25 Apr 2007 00:20:48 +0900 (JST)
Message-ID: <20070425.002048.109830535.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32841 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161798AbXDXPUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 11:20:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/Makefile |    4 ++--
 net/ipv4/proc.c   |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4ff6c15..3bd25f5 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -10,11 +10,11 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o \
+	     proc.o
 
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
-obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 97952d5..a236154 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -45,6 +45,7 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
+#ifdef CONFIG_PROC_FS
 static int fold_prot_inuse(struct proto *proto)
 {
 	int res = 0;
@@ -390,6 +391,7 @@ out_netstat:
 	rc = -ENOMEM;
 	goto out;
 }
+#endif
 
 int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
 {
-- 
1.5.1

