From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 4/9] IB/core: Add reserved values to enums for low-level drivers use
Date: Wed,  3 Jul 2013 20:13:07 +0300
Message-ID: <1372871592-32033-5-git-send-email-ogerlitz@mellanox.com>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jackm@dev.mellanox.co.il,
	eli@dev.mellanox.co.il, moshel@mellanox.com
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55342 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755355Ab3GCRNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jul 2013 13:13:33 -0400
In-Reply-To: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Continue the approach taken by commit d2b57063e4a "IB/core: Reserve bits in 
enum ib_qp_create_flags for low-level driver use" and "reserved" entries to 
the ib_qp_type and ib_wr_opcode enums. The low-level drivers will then define 
macros to use these reserved values, giving proper names to the macros for 
readability. Also add a range of reserved flags to enum ib_send_flags.

The mlx5 IB driver uses the new additions.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 include/rdma/ib_verbs.h |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 98cc4b2..645c3ce 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -610,7 +610,21 @@ enum ib_qp_type {
 	IB_QPT_RAW_PACKET = 8,
 	IB_QPT_XRC_INI = 9,
 	IB_QPT_XRC_TGT,
-	IB_QPT_MAX
+	IB_QPT_MAX,
+	/* Reserve a range for qp types internal to the low level driver.
+	 * These qp types will not be visible at the IB core layer, so the
+	 * IB_QPT_MAX usages should not be affected in the core layer
+	 */
+	IB_QPT_RESERVED1 = 0x1000,
+	IB_QPT_RESERVED2,
+	IB_QPT_RESERVED3,
+	IB_QPT_RESERVED4,
+	IB_QPT_RESERVED5,
+	IB_QPT_RESERVED6,
+	IB_QPT_RESERVED7,
+	IB_QPT_RESERVED8,
+	IB_QPT_RESERVED9,
+	IB_QPT_RESERVED10,
 };
 
 enum ib_qp_create_flags {
@@ -766,6 +780,19 @@ enum ib_wr_opcode {
 	IB_WR_MASKED_ATOMIC_CMP_AND_SWP,
 	IB_WR_MASKED_ATOMIC_FETCH_AND_ADD,
 	IB_WR_BIND_MW,
+	/* reserve values for low level drivers' internal use.
+	 * These values will not be used at all in the ib core layer.
+	 */
+	IB_WR_RESERVED1 = 0xf0,
+	IB_WR_RESERVED2,
+	IB_WR_RESERVED3,
+	IB_WR_RESERVED4,
+	IB_WR_RESERVED5,
+	IB_WR_RESERVED6,
+	IB_WR_RESERVED7,
+	IB_WR_RESERVED8,
+	IB_WR_RESERVED9,
+	IB_WR_RESERVED10,
 };
 
 enum ib_send_flags {
@@ -773,7 +800,11 @@ enum ib_send_flags {
 	IB_SEND_SIGNALED	= (1<<1),
 	IB_SEND_SOLICITED	= (1<<2),
 	IB_SEND_INLINE		= (1<<3),
-	IB_SEND_IP_CSUM		= (1<<4)
+	IB_SEND_IP_CSUM		= (1<<4),
+
+	/* reserve bits 26-31 for low level drivers' internal use */
+	IB_SEND_RESERVED_START	= (1 << 26),
+	IB_SEND_RESERVED_END	= (1 << 31),
 };
 
 struct ib_sge {
-- 
1.7.1
