From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 7/11][IPV6] Make the ipv6/sysctl_net_ipv6.c compilation
 cleaner
Date: Tue, 04 Dec 2007 13:11:23 +0300
Message-ID: <475527CB.9000003@openvz.org>
References: <4755256F.9000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39070 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbXLDKLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:11:38 -0500
In-Reply-To: <4755256F.9000505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this file is entirely enclosed with the 
#ifdef CONFIG_SYSCTL/#endif pair, it's OK to move this
CONFIG_ into a Makefile.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 5ffa980..24f3aa0 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -8,9 +8,9 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
-		exthdrs.o sysctl_net_ipv6.o datagram.o \
-		ip6_flowlabel.o inet6_connection_sock.o
+		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
+ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 68bb254..227efa7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -14,8 +14,6 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-#ifdef CONFIG_SYSCTL
-
 static ctl_table ipv6_table[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,
@@ -115,8 +113,3 @@ void ipv6_sysctl_unregister(void)
 {
 	unregister_sysctl_table(ipv6_sysctl_header);
 }
-
-#endif /* CONFIG_SYSCTL */
-
-
-
-- 
1.5.3.4

