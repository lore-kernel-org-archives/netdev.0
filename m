From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/25] net: Add flowiX_to_flowi() shorthands.
Date: Sat, 12 Mar 2011 15:27:04 -0800 (PST)
Message-ID: <20110312.152704.28813461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756185Ab1CLX00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:26:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2DB2F24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:27:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is just a shorthand which will help in passing around AF
specific flow structures as generic ones.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 9311690..8139257 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -112,6 +112,21 @@ struct flowi {
 #define fl6_gre_key	u.ip6.uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
+static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
+{
+	return container_of(fl4, struct flowi, u.ip4);
+}
+
+static inline struct flowi *flowi6_to_flowi(struct flowi6 *fl6)
+{
+	return container_of(fl6, struct flowi, u.ip6);
+}
+
+static inline struct flowi *flowidn_to_flowi(struct flowidn *fldn)
+{
+	return container_of(fldn, struct flowi, u.dn);
+}
+
 #define FLOW_DIR_IN	0
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
-- 
1.7.4.1

