From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Add a statistics counter for tx hash miss
Date: Mon, 21 Jul 2008 10:48:08 +0200
Message-ID: <1216630088-10328-2-git-send-email-andi@firstfloor.org>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:28337 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439AbYGUIsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 04:48:18 -0400
In-Reply-To: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@basil.nowhere.org>

Add a counter for the case when the TX hash function doesn't work.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/snmp.h |    1 +
 net/core/dev.c       |    3 +++
 net/ipv4/proc.c      |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 5df62ef..c4d69b7 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -214,6 +214,7 @@ enum
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
+	LINUX_MIB_TXHASHMISS,			/* TxHashMiss */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index c35fefc..cc45878 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -124,6 +124,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/in.h>
+#include <net/ip.h>
 
 #include "net-sysfs.h"
 
@@ -1688,6 +1689,7 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 		alen = 8;
 		break;
 	default:
+		NET_INC_STATS_BH(dev_net(dev), LINUX_MIB_TXHASHMISS);
 		return 0;
 	}
 
@@ -1712,6 +1714,7 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 		break;
 
 	default:
+		NET_INC_STATS_BH(dev_net(dev), LINUX_MIB_TXHASHMISS);
 		break;
 	}
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 834356e..f621b87 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -232,6 +232,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUNDO),
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
+	SNMP_MIB_ITEM("TxHashMiss", LINUX_MIB_TXHASHMISS),
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.5.6

