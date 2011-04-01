From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7] net: Add helper flowi4_init_output().
Date: Thu, 31 Mar 2011 17:12:11 -0700 (PDT)
Message-ID: <20110331.171211.48512691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753026Ab1DAAMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7213724C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On-stack initialization via assignment of flow structures are
expensive because GCC emits a memset() to clear the entire
structure out no matter what.

Add a helper for ipv4 output flow key setup which we can use to avoid
the memset.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 7fe5a0f..37e77d6 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -70,6 +70,27 @@ struct flowi4 {
 #define fl4_gre_key		uli.gre_key
 };
 
+static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
+				      __u32 mark, __u8 tos, __u8 scope,
+				      __u8 proto, __u8 flags,
+				      __be32 daddr, __be32 saddr,
+				      __be16 dport, __be32 sport)
+{
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_iif = 0;
+	fl4->flowi4_mark = mark;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_scope = scope;
+	fl4->flowi4_proto = proto;
+	fl4->flowi4_flags = flags;
+	fl4->flowi4_secid = 0;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+	fl4->fl4_sport = sport;
+	fl4->fl4_dport = dport;
+}
+				      
+
 struct flowi6 {
 	struct flowi_common	__fl_common;
 #define flowi6_oif		__fl_common.flowic_oif
-- 
1.7.4.2

