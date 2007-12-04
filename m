From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 3/11][IPv4] Cleanup the sysctl_net_ipv4.c file
Date: Tue, 04 Dec 2007 13:06:42 +0300
Message-ID: <475526B2.9040301@openvz.org>
References: <4755256F.9000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51406 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804AbXLDKG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:06:57 -0500
In-Reply-To: <4755256F.9000505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes several cleanups:

 * tune Makefile to compile out this file when SYSCTL=n. Now
   it looks like net/core/sysctl_net_core.c one;
 * move the ipv4_config to af_inet.c to exist all the time;
 * remove additional sysctl_ip_nonlocal_bind declaration
   (it is already declared in net/ip.h);
 * remove no nonger needed ifdefs from this file.

This is a preparation for using ctl paths for net/ipv4/
sysctl table.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 93fe396..ad40ef3 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -10,9 +10,10 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_minisocks.o tcp_cong.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o \
+	     fib_frontend.o fib_semantics.o \
 	     inet_fragment.o
 
+obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
 obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
 obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
 obj-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c75f20b..0e4b6eb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -126,6 +126,10 @@ extern void ip_mc_drop_socket(struct sock *sk);
 static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);
 
+struct ipv4_config ipv4_config;
+
+EXPORT_SYMBOL(ipv4_config);
+
 /* New destruction routine */
 
 void inet_sock_destruct(struct sock *sk)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index bec6fe8..3546424 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -21,19 +21,10 @@
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
 
-/* From af_inet.c */
-extern int sysctl_ip_nonlocal_bind;
-
-#ifdef CONFIG_SYSCTL
 static int zero;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
-#endif
-
-struct ipv4_config ipv4_config;
-
-#ifdef CONFIG_SYSCTL
 
 static
 int ipv4_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
@@ -887,7 +878,3 @@ ctl_table ipv4_table[] = {
 	},
 	{ .ctl_name = 0 }
 };
-
-#endif /* CONFIG_SYSCTL */
-
-EXPORT_SYMBOL(ipv4_config);
-- 
1.5.3.4

