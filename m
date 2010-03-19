From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: snmp mib cleanup
Date: Fri, 19 Mar 2010 07:36:06 +0100
Message-ID: <1268980566.2894.231.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:51248 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab0CSGgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 02:36:15 -0400
Received: by bwz1 with SMTP id 1so2697469bwz.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 23:36:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point to align or pad mibs to cache lines, they are per cpu
allocated with a 8 bytes alignment anyway.
This wastes space for no gain. This patch removes __SNMP_MIB_ALIGN__

Since SNMP mibs contain "unsigned long" fields only, we can relax the
allocation alignment from "unsigned long long" to "unsigned long"

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sctp/sctp.h |    2 +-
 include/net/snmp.h      |   29 +++++++----------------------
 net/dccp/dccp.h         |    2 +-
 net/ipv4/af_inet.c      |    4 ++--
 4 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 78740ec..5915155 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -268,7 +268,7 @@ enum {
 #define SCTP_MIB_MAX    __SCTP_MIB_MAX
 struct sctp_mib {
         unsigned long   mibs[SCTP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 
 /* Print debugging messages.  */
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 692ee00..884fdbb 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -52,26 +52,11 @@ struct snmp_mib {
  * count on the 20Gb/s + networks people expect in a few years time!
  */
 
-/* 
- * The rule for padding: 
- * Best is power of two because then the right structure can be found by a 
- * simple shift. The structure should be always cache line aligned.
- * gcc needs n=alignto(cachelinesize, popcnt(sizeof(bla_mib))) shift/add 
- * instructions to emulate multiply in case it is not power-of-two. 
- * Currently n is always <=3 for all sizes so simple cache line alignment 
- * is enough. 
- * 
- * The best solution would be a global CPU local area , especially on 64 
- * and 128byte cacheline machine it makes a *lot* of sense -AK
- */ 
-
-#define __SNMP_MIB_ALIGN__	____cacheline_aligned
-
 /* IPstats */
 #define IPSTATS_MIB_MAX	__IPSTATS_MIB_MAX
 struct ipstats_mib {
 	unsigned long	mibs[IPSTATS_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 /* ICMP */
 #define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
@@ -79,36 +64,36 @@ struct ipstats_mib {
 
 struct icmp_mib {
 	unsigned long	mibs[ICMP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 #define ICMPMSG_MIB_MAX	__ICMPMSG_MIB_MAX
 struct icmpmsg_mib {
 	unsigned long	mibs[ICMPMSG_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 /* ICMP6 (IPv6-ICMP) */
 #define ICMP6_MIB_MAX	__ICMP6_MIB_MAX
 struct icmpv6_mib {
 	unsigned long	mibs[ICMP6_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 #define ICMP6MSG_MIB_MAX  __ICMP6MSG_MIB_MAX
 struct icmpv6msg_mib {
 	unsigned long	mibs[ICMP6MSG_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 
 /* TCP */
 #define TCP_MIB_MAX	__TCP_MIB_MAX
 struct tcp_mib {
 	unsigned long	mibs[TCP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 /* UDP */
 #define UDP_MIB_MAX	__UDP_MIB_MAX
 struct udp_mib {
 	unsigned long	mibs[UDP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 /* Linux */
 #define LINUX_MIB_MAX	__LINUX_MIB_MAX
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 5ef32c2..53f8e12 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -189,7 +189,7 @@ enum {
 #define DCCP_MIB_MAX	__DCCP_MIB_MAX
 struct dccp_mib {
 	unsigned long	mibs[DCCP_MIB_MAX];
-} __SNMP_MIB_ALIGN__;
+};
 
 DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
 #define DCCP_INC_STATS(field)	    SNMP_INC_STATS(dccp_statistics, field)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 33b7dff..55e1190 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1401,10 +1401,10 @@ EXPORT_SYMBOL_GPL(snmp_fold_field);
 int snmp_mib_init(void __percpu *ptr[2], size_t mibsize)
 {
 	BUG_ON(ptr == NULL);
-	ptr[0] = __alloc_percpu(mibsize, __alignof__(unsigned long long));
+	ptr[0] = __alloc_percpu(mibsize, __alignof__(unsigned long));
 	if (!ptr[0])
 		goto err0;
-	ptr[1] = __alloc_percpu(mibsize, __alignof__(unsigned long long));
+	ptr[1] = __alloc_percpu(mibsize, __alignof__(unsigned long));
 	if (!ptr[1])
 		goto err1;
 	return 0;


