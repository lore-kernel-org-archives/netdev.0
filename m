From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next 1/3] net: l2tp: export debug flags to UAPI
Date: Sun, 11 Dec 2016 00:18:57 +0000
Message-ID: <20161211001859.10333-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the L2TP_MSG_* definitions to UAPI, as it is part of
the netlink API.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 include/uapi/linux/l2tp.h | 17 ++++++++++++++++-
 net/l2tp/l2tp_core.h      | 10 ----------
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 5daa48e..85ddb74 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -108,7 +108,7 @@ enum {
 	L2TP_ATTR_VLAN_ID,		/* u16 */
 	L2TP_ATTR_COOKIE,		/* 0, 4 or 8 bytes */
 	L2TP_ATTR_PEER_COOKIE,		/* 0, 4 or 8 bytes */
-	L2TP_ATTR_DEBUG,		/* u32 */
+	L2TP_ATTR_DEBUG,		/* u32, enum l2tp_debug_flags */
 	L2TP_ATTR_RECV_SEQ,		/* u8 */
 	L2TP_ATTR_SEND_SEQ,		/* u8 */
 	L2TP_ATTR_LNS_MODE,		/* u8 */
@@ -175,6 +175,21 @@ enum l2tp_seqmode {
 	L2TP_SEQ_ALL = 2,
 };
 
+/**
+ * enum l2tp_debug_flags - debug message categories for L2TP tunnels/sessions
+ *
+ * @L2TP_MSG_DEBUG: verbose debug (if compiled in)
+ * @L2TP_MSG_CONTROL: userspace - kernel interface
+ * @L2TP_MSG_SEQ: sequence numbers
+ * @L2TP_MSG_DATA: data packets
+ */
+enum l2tp_debug_flags {
+	L2TP_MSG_DEBUG		= (1 << 0),
+	L2TP_MSG_CONTROL	= (1 << 1),
+	L2TP_MSG_SEQ		= (1 << 2),
+	L2TP_MSG_DATA		= (1 << 3),
+};
+
 /*
  * NETLINK_GENERIC related info
  */
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 2599af6..8f560f7 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -23,16 +23,6 @@
 #define L2TP_HASH_BITS_2	8
 #define L2TP_HASH_SIZE_2	(1 << L2TP_HASH_BITS_2)
 
-/* Debug message categories for the DEBUG socket option */
-enum {
-	L2TP_MSG_DEBUG		= (1 << 0),	/* verbose debug (if
-						 * compiled in) */
-	L2TP_MSG_CONTROL	= (1 << 1),	/* userspace - kernel
-						 * interface */
-	L2TP_MSG_SEQ		= (1 << 2),	/* sequence numbers */
-	L2TP_MSG_DATA		= (1 << 3),	/* data packets */
-};
-
 struct sk_buff;
 
 struct l2tp_stats {
-- 
2.10.2
