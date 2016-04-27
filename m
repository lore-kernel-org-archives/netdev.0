From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 17/17] net: snmp: kill STATS_BH macros
Date: Wed, 27 Apr 2016 16:44:43 -0700
Message-ID: <1461800683-25034-18-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34251 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbcD0Xpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:33 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so26277215pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:32 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing related to BH in SNMP counters anymore,
since linux-3.0.

Rename helpers to use __ prefix instead of _BH prefix,
for contexts where preemption is disabled.

This more closely matches convention used to update
percpu variables.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/icmp.h      |  2 +-
 include/net/ip.h        | 10 +++++-----
 include/net/ipv6.h      | 36 ++++++++++++++++++------------------
 include/net/sctp/sctp.h |  6 +++---
 include/net/snmp.h      | 24 ++++++++++++------------
 include/net/tcp.h       |  2 +-
 include/net/udp.h       |  8 ++++----
 net/dccp/dccp.h         |  2 +-
 8 files changed, 45 insertions(+), 45 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 25edb740c648..3ef2743a8eec 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -30,7 +30,7 @@ struct icmp_err {
 
 extern const struct icmp_err icmp_err_convert[];
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
-#define __ICMP_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
+#define __ICMP_INC_STATS(net, field)	__SNMP_INC_STATS((net)->mib.icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field+256)
 #define ICMPMSGIN_INC_STATS(net, field)		SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
 
diff --git a/include/net/ip.h b/include/net/ip.h
index fb3b766ca1c7..247ac82e9cf2 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -187,15 +187,15 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 			   unsigned int len);
 
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
-#define __IP_INC_STATS(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
+#define __IP_INC_STATS(net, field)	__SNMP_INC_STATS64((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
-#define __IP_ADD_STATS(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define __IP_ADD_STATS(net, field, val) __SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
-#define __IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define __IP_UPD_PO_STATS(net, field, val) __SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
-#define __NET_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
+#define __NET_INC_STATS(net, field)	__SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_ADD_STATS(net, field, adnd)	SNMP_ADD_STATS((net)->mib.net_statistics, field, adnd)
-#define __NET_ADD_STATS(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
+#define __NET_ADD_STATS(net, field, adnd) __SNMP_ADD_STATS((net)->mib.net_statistics, field, adnd)
 
 u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offct);
 unsigned long snmp_fold_field(void __percpu *mib, int offt);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 64ce3670d40a..415213da5be3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -121,21 +121,21 @@ struct frag_hdr {
 extern int sysctl_mld_max_msf;
 extern int sysctl_mld_qrv;
 
-#define _DEVINC(net, statname, modifier, idev, field)			\
+#define _DEVINC(net, statname, mod, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
 	if (likely(_idev != NULL))					\
-		SNMP_INC_STATS##modifier((_idev)->stats.statname, (field)); \
-	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
+		mod##SNMP_INC_STATS64((_idev)->stats.statname, (field));\
+	mod##SNMP_INC_STATS64((net)->mib.statname##_statistics, (field));\
 })
 
 /* per device counters are atomic_long_t */
-#define _DEVINCATOMIC(net, statname, modifier, idev, field)		\
+#define _DEVINCATOMIC(net, statname, mod, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
 	if (likely(_idev != NULL))					\
 		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field)); \
-	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
+	mod##SNMP_INC_STATS((net)->mib.statname##_statistics, (field));\
 })
 
 /* per device and per net counters are atomic_long_t */
@@ -147,40 +147,40 @@ extern int sysctl_mld_qrv;
 	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.statname##_statistics, (field));\
 })
 
-#define _DEVADD(net, statname, modifier, idev, field, val)		\
+#define _DEVADD(net, statname, mod, idev, field, val)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
 	if (likely(_idev != NULL))					\
-		SNMP_ADD_STATS##modifier((_idev)->stats.statname, (field), (val)); \
-	SNMP_ADD_STATS##modifier((net)->mib.statname##_statistics, (field), (val));\
+		mod##SNMP_ADD_STATS((_idev)->stats.statname, (field), (val)); \
+	mod##SNMP_ADD_STATS((net)->mib.statname##_statistics, (field), (val));\
 })
 
-#define _DEVUPD(net, statname, modifier, idev, field, val)		\
+#define _DEVUPD(net, statname, mod, idev, field, val)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
 	if (likely(_idev != NULL))					\
-		SNMP_UPD_PO_STATS##modifier((_idev)->stats.statname, field, (val)); \
-	SNMP_UPD_PO_STATS##modifier((net)->mib.statname##_statistics, field, (val));\
+		mod##SNMP_UPD_PO_STATS((_idev)->stats.statname, field, (val)); \
+	mod##SNMP_UPD_PO_STATS((net)->mib.statname##_statistics, field, (val));\
 })
 
 /* MIBs */
 
 #define IP6_INC_STATS(net, idev,field)		\
-		_DEVINC(net, ipv6, 64, idev, field)
+		_DEVINC(net, ipv6, , idev, field)
 #define __IP6_INC_STATS(net, idev,field)	\
-		_DEVINC(net, ipv6, 64_BH, idev, field)
+		_DEVINC(net, ipv6, __, idev, field)
 #define IP6_ADD_STATS(net, idev,field,val)	\
-		_DEVADD(net, ipv6, 64, idev, field, val)
+		_DEVADD(net, ipv6, , idev, field, val)
 #define __IP6_ADD_STATS(net, idev,field,val)	\
-		_DEVADD(net, ipv6, 64_BH, idev, field, val)
+		_DEVADD(net, ipv6, __, idev, field, val)
 #define IP6_UPD_PO_STATS(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, 64, idev, field, val)
+		_DEVUPD(net, ipv6, , idev, field, val)
 #define __IP6_UPD_PO_STATS(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
+		_DEVUPD(net, ipv6, __, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINCATOMIC(net, icmpv6, , idev, field)
 #define __ICMP6_INC_STATS(net, idev, field)	\
-		_DEVINCATOMIC(net, icmpv6, _BH, idev, field)
+		_DEVINCATOMIC(net, icmpv6, __, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
 	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 5607c009f738..b392ac8382f2 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -205,9 +205,9 @@ extern int sysctl_sctp_wmem[3];
  */
 
 /* SCTP SNMP MIB stats handlers */
-#define SCTP_INC_STATS(net, field)      SNMP_INC_STATS((net)->sctp.sctp_statistics, field)
-#define __SCTP_INC_STATS(net, field)   SNMP_INC_STATS_BH((net)->sctp.sctp_statistics, field)
-#define SCTP_DEC_STATS(net, field)      SNMP_DEC_STATS((net)->sctp.sctp_statistics, field)
+#define SCTP_INC_STATS(net, field)	SNMP_INC_STATS((net)->sctp.sctp_statistics, field)
+#define __SCTP_INC_STATS(net, field)	__SNMP_INC_STATS((net)->sctp.sctp_statistics, field)
+#define SCTP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->sctp.sctp_statistics, field)
 
 /* sctp mib definitions */
 enum {
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 56239fc05c51..6bdd255b2250 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -123,7 +123,7 @@ struct linux_xfrm_mib {
 #define DECLARE_SNMP_STAT(type, name)	\
 	extern __typeof__(type) __percpu *name
 
-#define SNMP_INC_STATS_BH(mib, field)	\
+#define __SNMP_INC_STATS(mib, field)	\
 			__this_cpu_inc(mib->mibs[field])
 
 #define SNMP_INC_STATS_ATOMIC_LONG(mib, field)	\
@@ -135,7 +135,7 @@ struct linux_xfrm_mib {
 #define SNMP_DEC_STATS(mib, field)	\
 			this_cpu_dec(mib->mibs[field])
 
-#define SNMP_ADD_STATS_BH(mib, field, addend)	\
+#define __SNMP_ADD_STATS(mib, field, addend)	\
 			__this_cpu_add(mib->mibs[field], addend)
 
 #define SNMP_ADD_STATS(mib, field, addend)	\
@@ -146,7 +146,7 @@ struct linux_xfrm_mib {
 		this_cpu_inc(ptr[basefield##PKTS]);		\
 		this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
-#define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
+#define __SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
 		__typeof__((mib->mibs) + 0) ptr = mib->mibs;	\
 		__this_cpu_inc(ptr[basefield##PKTS]);		\
@@ -156,7 +156,7 @@ struct linux_xfrm_mib {
 
 #if BITS_PER_LONG==32
 
-#define SNMP_ADD_STATS64_BH(mib, field, addend) 			\
+#define __SNMP_ADD_STATS64(mib, field, addend) 				\
 	do {								\
 		__typeof__(*mib) *ptr = raw_cpu_ptr(mib);		\
 		u64_stats_update_begin(&ptr->syncp);			\
@@ -164,16 +164,16 @@ struct linux_xfrm_mib {
 		u64_stats_update_end(&ptr->syncp);			\
 	} while (0)
 
-#define SNMP_ADD_STATS64(mib, field, addend) 			\
+#define SNMP_ADD_STATS64(mib, field, addend) 				\
 	do {								\
 		preempt_disable();					\
-		SNMP_ADD_STATS64_BH(mib, field, addend);		\
+		__SNMP_ADD_STATS64(mib, field, addend);			\
 		preempt_enable();					\
 	} while (0)
 
-#define SNMP_INC_STATS64_BH(mib, field) SNMP_ADD_STATS64_BH(mib, field, 1)
+#define __SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
 #define SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
-#define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
+#define __SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
 	do {								\
 		__typeof__(*mib) *ptr;				\
 		ptr = raw_cpu_ptr((mib));				\
@@ -185,17 +185,17 @@ struct linux_xfrm_mib {
 #define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
 	do {								\
 		preempt_disable();					\
-		SNMP_UPD_PO_STATS64_BH(mib, basefield, addend);		\
+		__SNMP_UPD_PO_STATS64(mib, basefield, addend);		\
 		preempt_enable();					\
 	} while (0)
 #else
-#define SNMP_INC_STATS64_BH(mib, field)		SNMP_INC_STATS_BH(mib, field)
+#define __SNMP_INC_STATS64(mib, field)		__SNMP_INC_STATS(mib, field)
 #define SNMP_INC_STATS64(mib, field)		SNMP_INC_STATS(mib, field)
 #define SNMP_DEC_STATS64(mib, field)		SNMP_DEC_STATS(mib, field)
-#define SNMP_ADD_STATS64_BH(mib, field, addend) SNMP_ADD_STATS_BH(mib, field, addend)
+#define __SNMP_ADD_STATS64(mib, field, addend)	__SNMP_ADD_STATS(mib, field, addend)
 #define SNMP_ADD_STATS64(mib, field, addend)	SNMP_ADD_STATS(mib, field, addend)
 #define SNMP_UPD_PO_STATS64(mib, basefield, addend) SNMP_UPD_PO_STATS(mib, basefield, addend)
-#define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend) SNMP_UPD_PO_STATS_BH(mib, basefield, addend)
+#define __SNMP_UPD_PO_STATS64(mib, basefield, addend) __SNMP_UPD_PO_STATS(mib, basefield, addend)
 #endif
 
 #endif
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ff8b4265cb2b..992f317c1abe 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -332,7 +332,7 @@ bool tcp_check_oom(struct sock *sk, int shift);
 extern struct proto tcp_prot;
 
 #define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
-#define __TCP_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
+#define __TCP_INC_STATS(net, field)	__SNMP_INC_STATS((net)->mib.tcp_statistics, field)
 #define TCP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->mib.tcp_statistics, field)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
diff --git a/include/net/udp.h b/include/net/udp.h
index bf6a7c29cf6a..ae07f375370d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -293,12 +293,12 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 	if (is_udplite) SNMP_INC_STATS((net)->mib.udplite_statistics, field);       \
 	else		SNMP_INC_STATS((net)->mib.udp_statistics, field);  }  while(0)
 #define __UDP_INC_STATS(net, field, is_udplite) 	      do { \
-	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_statistics, field);         \
-	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
+	if (is_udplite) __SNMP_INC_STATS((net)->mib.udplite_statistics, field);         \
+	else		__SNMP_INC_STATS((net)->mib.udp_statistics, field);    }  while(0)
 
 #define __UDP6_INC_STATS(net, field, is_udplite)	    do { \
-	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_stats_in6, field);\
-	else		SNMP_INC_STATS_BH((net)->mib.udp_stats_in6, field);  \
+	if (is_udplite) __SNMP_INC_STATS((net)->mib.udplite_stats_in6, field);\
+	else		__SNMP_INC_STATS((net)->mib.udp_stats_in6, field);  \
 } while(0)
 #define UDP6_INC_STATS(net, field, __lite)		    do { \
 	if (__lite) SNMP_INC_STATS((net)->mib.udplite_stats_in6, field);  \
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index a4c6e2fed91c..0c55ffb859bf 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -199,7 +199,7 @@ struct dccp_mib {
 
 DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
 #define DCCP_INC_STATS(field)	SNMP_INC_STATS(dccp_statistics, field)
-#define __DCCP_INC_STATS(field)	SNMP_INC_STATS_BH(dccp_statistics, field)
+#define __DCCP_INC_STATS(field)	__SNMP_INC_STATS(dccp_statistics, field)
 #define DCCP_DEC_STATS(field)	SNMP_DEC_STATS(dccp_statistics, field)
 
 /*
-- 
2.8.0.rc3.226.g39d4020
