From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: [PATCH 1/2] irda: Use __packed annotation instead IRDA_PACKED macro
Date: Wed, 21 Jul 2010 17:59:57 -0300
Message-ID: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove IRDA_PACKED macro, which maps to __attribute__((packed)). IRDA is
one of the last users of __attribute__((packet)). Networking code uses
__packed now.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
---
 include/net/irda/irda.h        |    4 ----
 include/net/irda/irlap_frame.h |   18 +++++++++---------
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 7e58206..3bed61d 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -53,10 +53,6 @@ typedef __u32 magic_t;
 #ifndef IRDA_ALIGN
 #  define IRDA_ALIGN __attribute__((aligned))
 #endif
-#ifndef IRDA_PACK
-#  define IRDA_PACK __attribute__((packed))
-#endif
-
 
 #ifdef CONFIG_IRDA_DEBUG
 
diff --git a/include/net/irda/irlap_frame.h b/include/net/irda/irlap_frame.h
index 641f88e..6b1dc4f 100644
--- a/include/net/irda/irlap_frame.h
+++ b/include/net/irda/irlap_frame.h
@@ -85,7 +85,7 @@ struct discovery_t;
 struct disc_frame {
 	__u8 caddr;          /* Connection address */
 	__u8 control;
-} IRDA_PACK;
+} __packed;
 
 struct xid_frame {
 	__u8  caddr; /* Connection address */
@@ -96,41 +96,41 @@ struct xid_frame {
 	__u8  flags; /* Discovery flags */
 	__u8  slotnr;
 	__u8  version;
-} IRDA_PACK;
+} __packed;
 
 struct test_frame {
 	__u8 caddr;          /* Connection address */
 	__u8 control;
 	__le32 saddr;         /* Source device address */
 	__le32 daddr;         /* Destination device address */
-} IRDA_PACK;
+} __packed;
 
 struct ua_frame {
 	__u8 caddr;
 	__u8 control;
 	__le32 saddr; /* Source device address */
 	__le32 daddr; /* Dest device address */
-} IRDA_PACK;
+} __packed;
 
 struct dm_frame {
 	__u8 caddr;          /* Connection address */
 	__u8 control;
-} IRDA_PACK;
+} __packed;
 
 struct rd_frame {
 	__u8 caddr;          /* Connection address */
 	__u8 control;
-} IRDA_PACK;
+} __packed;
 
 struct rr_frame {
 	__u8 caddr;          /* Connection address */
 	__u8 control;
-} IRDA_PACK;
+} __packed;
 
 struct i_frame {
 	__u8 caddr;
 	__u8 control;
-} IRDA_PACK;
+} __packed;
 
 struct snrm_frame {
 	__u8  caddr;
@@ -138,7 +138,7 @@ struct snrm_frame {
 	__le32 saddr;
 	__le32 daddr;
 	__u8  ncaddr;
-} IRDA_PACK;
+} __packed;
 
 void irlap_queue_xmit(struct irlap_cb *self, struct sk_buff *skb);
 void irlap_send_discovery_xid_frame(struct irlap_cb *, int S, __u8 s, 
-- 
1.7.1.1
