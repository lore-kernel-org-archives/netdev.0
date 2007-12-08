From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [NET]: Remove unused "mibalign" argument for
 snmp_mib_init().
Date: Sat, 08 Dec 2007 00:41:28 -0800 (PST)
Message-ID: <20071208.004128.44758266.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43052 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbXLHIlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:41:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/include/net/ip.h b/include/net/ip.h
index 840dd91..7f18819 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -169,7 +169,7 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
 extern unsigned long snmp_fold_field(void *mib[], int offt);
-extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
+extern int snmp_mib_init(void *ptr[2], size_t mibsize);
 extern void snmp_mib_free(void *ptr[2]);
 
 extern void inet_get_local_port_range(int *low, int *high);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d2f22e7..afee63e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1237,7 +1237,7 @@ unsigned long snmp_fold_field(void *mib[], int offt)
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
-int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
+int snmp_mib_init(void *ptr[2], size_t mibsize)
 {
 	BUG_ON(ptr == NULL);
 	ptr[0] = __alloc_percpu(mibsize);
@@ -1291,32 +1291,25 @@ static struct net_protocol icmp_protocol = {
 static int __init init_ipv4_mibs(void)
 {
 	if (snmp_mib_init((void **)net_statistics,
-			  sizeof(struct linux_mib),
-			  __alignof__(struct linux_mib)) < 0)
+			  sizeof(struct linux_mib)) < 0)
 		goto err_net_mib;
 	if (snmp_mib_init((void **)ip_statistics,
-			  sizeof(struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
 	if (snmp_mib_init((void **)icmp_statistics,
-			  sizeof(struct icmp_mib),
-			  __alignof__(struct icmp_mib)) < 0)
+			  sizeof(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
 	if (snmp_mib_init((void **)icmpmsg_statistics,
-			  sizeof(struct icmpmsg_mib),
-			  __alignof__(struct icmpmsg_mib)) < 0)
+			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
 	if (snmp_mib_init((void **)tcp_statistics,
-			  sizeof(struct tcp_mib),
-			  __alignof__(struct tcp_mib)) < 0)
+			  sizeof(struct tcp_mib)) < 0)
 		goto err_tcp_mib;
 	if (snmp_mib_init((void **)udp_statistics,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+			  sizeof(struct udp_mib)) < 0)
 		goto err_udp_mib;
 	if (snmp_mib_init((void **)udplite_statistics,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 
 	tcp_mib_init();
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d9a59e0..9d4896f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -257,16 +257,13 @@ static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
 static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
 	if (snmp_mib_init((void **)idev->stats.ipv6,
-			  sizeof(struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip;
 	if (snmp_mib_init((void **)idev->stats.icmpv6,
-			  sizeof(struct icmpv6_mib),
-			  __alignof__(struct icmpv6_mib)) < 0)
+			  sizeof(struct icmpv6_mib)) < 0)
 		goto err_icmp;
 	if (snmp_mib_init((void **)idev->stats.icmpv6msg,
-			  sizeof(struct icmpv6msg_mib),
-			  __alignof__(struct icmpv6msg_mib)) < 0)
+			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg;
 
 	return 0;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
