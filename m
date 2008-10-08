From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 12/14] ipv6: added net argument to _DEVINC/_DEVADD
Date: Wed,  8 Oct 2008 15:52:00 +0400
Message-ID: <1223466722-8169-12-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14354 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754396AbYJHLzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:55:41 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 47a76bf..d0538dd 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -110,17 +110,19 @@ struct frag_hdr {
 extern int sysctl_mld_max_msf;
 extern struct ctl_path net_ipv6_ctl_path[];
 
-#define _DEVINC(statname, modifier, idev, field)			\
+#define _DEVINC(net, statname, modifier, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
+	(void)(net);							\
 	if (likely(_idev != NULL))					\
 		SNMP_INC_STATS##modifier((_idev)->stats.statname, (field)); \
 	SNMP_INC_STATS##modifier(statname##_statistics, (field));	\
 })
 
-#define _DEVADD(statname, modifier, idev, field, val)			\
+#define _DEVADD(net, statname, modifier, idev, field, val)		\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
+	(void)(net);							\
 	if (likely(_idev != NULL))					\
 		SNMP_ADD_STATS##modifier((_idev)->stats.statname, (field), (val)); \
 	SNMP_ADD_STATS##modifier(statname##_statistics, (field), (val));\
@@ -129,27 +131,27 @@ extern struct ctl_path net_ipv6_ctl_path[];
 /* MIBs */
 DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 
-#define IP6_INC_STATS(net, idev,field)	({ (void)(net); \
-		_DEVINC(ipv6, , idev, field); })
-#define IP6_INC_STATS_BH(net, idev,field) ({ (void)(net); \
-		_DEVINC(ipv6, _BH, idev, field); })
-#define IP6_ADD_STATS_BH(net, idev,field,val) ({ (void)(net); \
-		_DEVADD(ipv6, _BH, idev, field, val); })
+#define IP6_INC_STATS(net, idev,field)		\
+		_DEVINC(net, ipv6, , idev, field)
+#define IP6_INC_STATS_BH(net, idev,field)	\
+		_DEVINC(net, ipv6, _BH, idev, field)
+#define IP6_ADD_STATS_BH(net, idev,field,val)	\
+		_DEVADD(net, ipv6, _BH, idev, field, val)
 
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 
-#define ICMP6_INC_STATS(net, idev, field)	({ (void)(net); \
-		_DEVINC(icmpv6, , idev, field); })
-#define ICMP6_INC_STATS_BH(net, idev, field)	({ (void)(net); \
-		_DEVINC(icmpv6, _BH, idev, field); })
-
-#define ICMP6MSGOUT_INC_STATS(net, idev, field) ({ (void)(net); \
-	_DEVINC(icmpv6msg, , idev, field +256); })
-#define ICMP6MSGOUT_INC_STATS_BH(net, idev, field) ({ (void)(net); \
-	_DEVINC(icmpv6msg, _BH, idev, field +256); })
-#define ICMP6MSGIN_INC_STATS_BH(net, idev, field) ({ (void)(net); \
-	_DEVINC(icmpv6msg, _BH, idev, field); })
+#define ICMP6_INC_STATS(net, idev, field)	\
+		_DEVINC(net, icmpv6, , idev, field)
+#define ICMP6_INC_STATS_BH(net, idev, field)	\
+		_DEVINC(net, icmpv6, _BH, idev, field)
+
+#define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
+	_DEVINC(net, icmpv6msg, , idev, field +256)
+#define ICMP6MSGOUT_INC_STATS_BH(net, idev, field)	\
+	_DEVINC(net, icmpv6msg, _BH, idev, field +256)
+#define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
+	_DEVINC(net, icmpv6msg, _BH, idev, field)
 
 struct ip6_ra_chain
 {
-- 
1.5.3.rc5

