From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25] Remove unused devconf macros
Date: Fri, 07 Dec 2007 13:16:43 +0300
Message-ID: <47591D8B.7000808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39345 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbXLGKRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 05:17:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SNMP_INC_STATS_OFFSET_BH is used only by ICMP6_INC_STATS_OFFSET_BH.
The ICMP6_INC_STATS_OFFSET_BH is unused.

Can we drop them?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a84f3f6..38df94b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -143,14 +143,6 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #define ICMP6_INC_STATS_BH(idev, field)	_DEVINC(icmpv6, _BH, idev, field)
 #define ICMP6_INC_STATS_USER(idev, field) _DEVINC(icmpv6, _USER, idev, field)
 
-#define ICMP6_INC_STATS_OFFSET_BH(idev, field, offset)	({			\
-	struct inet6_dev *_idev = idev;						\
-	__typeof__(offset) _offset = (offset);					\
-	if (likely(_idev != NULL))						\
-		SNMP_INC_STATS_OFFSET_BH(_idev->stats.icmpv6, field, _offset);	\
-	SNMP_INC_STATS_OFFSET_BH(icmpv6_statistics, field, _offset);    	\
-})
-
 #define ICMP6MSGOUT_INC_STATS(idev, field) \
 	_DEVINC(icmpv6msg, , idev, field +256)
 #define ICMP6MSGOUT_INC_STATS_BH(idev, field) \
diff --git a/include/net/snmp.h b/include/net/snmp.h
index ea206bf..9c5793d 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -134,8 +134,6 @@ struct linux_mib {
 
 #define SNMP_INC_STATS_BH(mib, field) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]++)
-#define SNMP_INC_STATS_OFFSET_BH(mib, field, offset)	\
-	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field + (offset)]++)
 #define SNMP_INC_STATS_USER(mib, field) \
 	(per_cpu_ptr(mib[1], raw_smp_processor_id())->mibs[field]++)
 #define SNMP_INC_STATS(mib, field) 	\
-- 
1.5.3.4

