From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/25] net: Create struct flowi_common
Date: Sat, 12 Mar 2011 15:26:03 -0800 (PST)
Message-ID: <20110312.152603.115934517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37570
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926Ab1CLXZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:25:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C322C24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:26:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pull out the AF independent members of struct flowi into a
new struct flowi_common

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8c4dbd0..7759687 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -10,18 +10,30 @@
 #include <linux/in6.h>
 #include <asm/atomic.h>
 
-struct flowi {
-	int	flowi_oif;
-	int	flowi_iif;
-	__u32	flowi_mark;
-	__u8	flowi_tos;
-	__u8	flowi_scope;
-	__u8	flowi_proto;
-	__u8	flowi_flags;
+struct flowi_common {
+	int	flowic_oif;
+	int	flowic_iif;
+	__u32	flowic_mark;
+	__u8	flowic_tos;
+	__u8	flowic_scope;
+	__u8	flowic_proto;
+	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_PRECOW_METRICS	0x02
 #define FLOWI_FLAG_CAN_SLEEP		0x04
-	__u32	flowi_secid;
+	__u32	flowic_secid;
+};
+
+struct flowi {
+	struct flowi_common	__fl_common;
+#define flowi_oif		__fl_common.flowic_oif
+#define flowi_iif		__fl_common.flowic_iif
+#define flowi_mark		__fl_common.flowic_mark
+#define flowi_tos		__fl_common.flowic_tos
+#define flowi_scope		__fl_common.flowic_scope
+#define flowi_proto		__fl_common.flowic_proto
+#define flowi_flags		__fl_common.flowic_flags
+#define flowi_secid		__fl_common.flowic_secid
 
 	union {
 		struct {
-- 
1.7.4.1

