From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/25] net: Create union flowi_uli
Date: Sat, 12 Mar 2011 15:26:19 -0800 (PST)
Message-ID: <20110312.152619.48504281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756186Ab1CLXZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:25:41 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 71A4024C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:26:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will be used when we have seperate flowi types.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |   48 +++++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 7759687..541ac13 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -24,6 +24,30 @@ struct flowi_common {
 	__u32	flowic_secid;
 };
 
+union flowi_uli {
+	struct {
+		__be16	sport;
+		__be16	dport;
+	} ports;
+
+	struct {
+		__u8	type;
+		__u8	code;
+	} icmpt;
+
+	struct {
+		__le16	sport;
+		__le16	dport;
+	} dnports;
+
+	__be32		spi;
+	__be32		gre_key;
+
+	struct {
+		__u8	type;
+	} mht;
+};
+
 struct flowi {
 	struct flowi_common	__fl_common;
 #define flowi_oif		__fl_common.flowic_oif
@@ -64,29 +88,7 @@ struct flowi {
 #define fl4_tos		flowi_tos
 #define fl4_scope	flowi_scope
 
-	union {
-		struct {
-			__be16	sport;
-			__be16	dport;
-		} ports;
-
-		struct {
-			__u8	type;
-			__u8	code;
-		} icmpt;
-
-		struct {
-			__le16	sport;
-			__le16	dport;
-		} dnports;
-
-		__be32		spi;
-		__be32		gre_key;
-
-		struct {
-			__u8	type;
-		} mht;
-	} uli_u;
+	union flowi_uli uli_u;
 #define fl_ip_sport	uli_u.ports.sport
 #define fl_ip_dport	uli_u.ports.dport
 #define fl_icmp_type	uli_u.icmpt.type
-- 
1.7.4.1

