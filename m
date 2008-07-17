From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/16] ipv4: add pernet mib operations
Date: Thu, 17 Jul 2008 17:23:19 +0400
Message-ID: <487F47C7.4030909@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39053 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbYGQNXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:23:24 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These ones are currently empty, but stuff from init_ipv4_mibs will
sequentially migrate there.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/af_inet.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 95a966d..b4b77aa 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -110,6 +110,7 @@
 #include <net/ipip.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
+#include <net/net_namespace.h>
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
@@ -1339,6 +1340,20 @@ static struct net_protocol icmp_protocol = {
 	.netns_ok =	1,
 };
 
+static __net_init int ipv4_mib_init_net(struct net *net)
+{
+	return 0;
+}
+
+static __net_exit void ipv4_mib_exit_net(struct net *net)
+{
+}
+
+static __net_initdata struct pernet_operations ipv4_mib_ops = {
+	.init = ipv4_mib_init_net,
+	.exit = ipv4_mib_exit_net,
+};
+
 static int __init init_ipv4_mibs(void)
 {
 	if (snmp_mib_init((void **)net_statistics,
@@ -1365,8 +1380,13 @@ static int __init init_ipv4_mibs(void)
 
 	tcp_mib_init(&init_net);
 
+	if (register_pernet_subsys(&ipv4_mib_ops))
+		goto err_net;
+
 	return 0;
 
+err_net:
+	snmp_mib_free((void **)udplite_statistics);
 err_udplite_mib:
 	snmp_mib_free((void **)udp_statistics);
 err_udp_mib:
-- 
1.5.5.1

