From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/25] net: Remove unnecessary padding in struct flowi
Date: Sat, 12 Mar 2011 15:25:08 -0800 (PST)
Message-ID: <20110312.152508.183050114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755053Ab1CLXYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:24:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id ED6DE24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:25:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move tos, scope, proto, and flags to the beginning of
the structure.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index fd04138..a661fd6 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -14,13 +14,19 @@ struct flowi {
 	int	oif;
 	int	iif;
 	__u32	mark;
+	__u8	tos;
+	__u8	scope;
+	__u8	proto;
+	__u8	flags;
+#define FLOWI_FLAG_ANYSRC		0x01
+#define FLOWI_FLAG_PRECOW_METRICS	0x02
+#define FLOWI_FLAG_CAN_SLEEP		0x04
+	__u32	secid;
 
 	union {
 		struct {
 			__be32			daddr;
 			__be32			saddr;
-			__u8			tos;
-			__u8			scope;
 		} ip4_u;
 		
 		struct {
@@ -43,14 +49,9 @@ struct flowi {
 #define fl6_flowlabel	nl_u.ip6_u.flowlabel
 #define fl4_dst		nl_u.ip4_u.daddr
 #define fl4_src		nl_u.ip4_u.saddr
-#define fl4_tos		nl_u.ip4_u.tos
-#define fl4_scope	nl_u.ip4_u.scope
+#define fl4_tos		tos
+#define fl4_scope	scope
 
-	__u8	proto;
-	__u8	flags;
-#define FLOWI_FLAG_ANYSRC		0x01
-#define FLOWI_FLAG_PRECOW_METRICS	0x02
-#define FLOWI_FLAG_CAN_SLEEP		0x04
 	union {
 		struct {
 			__be16	sport;
@@ -81,7 +82,6 @@ struct flowi {
 #define fl_ipsec_spi	uli_u.spi
 #define fl_mh_type	uli_u.mht.type
 #define fl_gre_key	uli_u.gre_key
-	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
-- 
1.7.4.1

