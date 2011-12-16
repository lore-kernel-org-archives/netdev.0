From: igorm@etf.rs
Subject: [PATCH 04/10 net-next] include:net:ipv6: Moved _DEV* macros
Date: Fri, 16 Dec 2011 16:25:57 +0100
Message-ID: <1324049163-11207-5-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53864 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759997Ab1LPP0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:19 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Moved _DEV* macros to /include/net/snmp.h so they
could be reused for ipv4 per device statistics.

Changed calling of _DEV* macros because they now have +1 argument - type.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/net/ipv6.h |   64 +++++++++-------------------------------------------
 1 files changed, 11 insertions(+), 53 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e4170a2..fe65b9b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -115,73 +115,31 @@ struct frag_hdr {
 extern int sysctl_mld_max_msf;
 extern struct ctl_path net_ipv6_ctl_path[];
 
-#define _DEVINC(net, statname, modifier, idev, field)			\
-({									\
-	struct inet6_dev *_idev = (idev);				\
-	if (likely(_idev != NULL))					\
-		SNMP_INC_STATS##modifier((_idev)->stats.statname, (field)); \
-	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
-})
-
-/* per device counters are atomic_long_t */
-#define _DEVINCATOMIC(net, statname, modifier, idev, field)		\
-({									\
-	struct inet6_dev *_idev = (idev);				\
-	if (likely(_idev != NULL))					\
-		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field)); \
-	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
-})
-
-/* per device and per net counters are atomic_long_t */
-#define _DEVINC_ATOMIC_ATOMIC(net, statname, idev, field)		\
-({									\
-	struct inet6_dev *_idev = (idev);				\
-	if (likely(_idev != NULL))					\
-		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field)); \
-	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.statname##_statistics, (field));\
-})
-
-#define _DEVADD(net, statname, modifier, idev, field, val)		\
-({									\
-	struct inet6_dev *_idev = (idev);				\
-	if (likely(_idev != NULL))					\
-		SNMP_ADD_STATS##modifier((_idev)->stats.statname, (field), (val)); \
-	SNMP_ADD_STATS##modifier((net)->mib.statname##_statistics, (field), (val));\
-})
-
-#define _DEVUPD(net, statname, modifier, idev, field, val)		\
-({									\
-	struct inet6_dev *_idev = (idev);				\
-	if (likely(_idev != NULL))					\
-		SNMP_UPD_PO_STATS##modifier((_idev)->stats.statname, field, (val)); \
-	SNMP_UPD_PO_STATS##modifier((net)->mib.statname##_statistics, field, (val));\
-})
-
 /* MIBs */
 
 #define IP6_INC_STATS(net, idev,field)		\
-		_DEVINC(net, ipv6, 64, idev, field)
+		_DEVINC(net, ipv6, 64, struct inet6_dev, idev, field)
 #define IP6_INC_STATS_BH(net, idev,field)	\
-		_DEVINC(net, ipv6, 64_BH, idev, field)
+		_DEVINC(net, ipv6, 64_BH, struct inet6_dev, idev, field)
 #define IP6_ADD_STATS(net, idev,field,val)	\
-		_DEVADD(net, ipv6, 64, idev, field, val)
+		_DEVADD(net, ipv6, 64, struct inet6_dev, idev, field, val)
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
-		_DEVADD(net, ipv6, 64_BH, idev, field, val)
+		_DEVADD(net, ipv6, 64_BH, struct inet6_dev, idev, field, val)
 #define IP6_UPD_PO_STATS(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, 64, idev, field, val)
+		_DEVUPD(net, ipv6, 64, struct inet6_dev, idev, field, val)
 #define IP6_UPD_PO_STATS_BH(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
+		_DEVUPD(net, ipv6, 64_BH, struct inet6_dev, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
-		_DEVINCATOMIC(net, icmpv6, , idev, field)
+		_DEVINCATOMIC(net, icmpv6, , struct inet6_dev, idev, field)
 #define ICMP6_INC_STATS_BH(net, idev, field)	\
-		_DEVINCATOMIC(net, icmpv6, _BH, idev, field)
+		_DEVINCATOMIC(net, icmpv6, _BH, struct inet6_dev, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
-	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, struct inet6_dev, idev, field +256)
 #define ICMP6MSGOUT_INC_STATS_BH(net, idev, field)	\
-	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, struct inet6_dev, idev, field +256)
 #define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
-	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, struct inet6_dev, idev, field)
 
 struct ip6_ra_chain {
 	struct ip6_ra_chain	*next;
-- 
1.7.5.4
