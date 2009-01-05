From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qlge: Fix sparse warnings for tx ring indexes.
Date: Mon,  5 Jan 2009 14:27:32 -0800
Message-ID: <1231194452-10671-5-git-send-email-ron.mercer@qlogic.com>
References: <20090105222600.GA4232@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZAEW1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:27:38 -0500
In-Reply-To: <20090105222600.GA4232@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warnings:
drivers/net/qlge/qlge_main.c:1474:34: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1475:36: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1592:51: warning: restricted degrades to integer
drivers/net/qlge/qlge_main.c:1941:20: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:1941:20:    expected restricted unsigned int [usertype] tid
drivers/net/qlge/qlge_main.c:1941:20:    got int [signed] index
drivers/net/qlge/qlge_main.c:1945:24: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:1945:24:    expected restricted unsigned int [usertype] txq_idx
drivers/net/qlge/qlge_main.c:1945:24:    got unsigned int [unsigned] [usertype] tx_ring_idx

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 76ef2bc..459663a 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -851,8 +851,8 @@ struct ob_mac_iocb_req {
 	__le16 frame_len;
 #define OB_MAC_IOCB_LEN_MASK 0x3ffff
 	__le16 reserved2;
-	__le32 tid;
-	__le32 txq_idx;
+	u32 tid;
+	u32 txq_idx;
 	__le32 reserved3;
 	__le16 vlan_tci;
 	__le16 reserved4;
@@ -871,8 +871,8 @@ struct ob_mac_iocb_rsp {
 	u8 flags2;		/* */
 	u8 flags3;		/* */
 #define OB_MAC_IOCB_RSP_B	0x80	/* */
-	__le32 tid;
-	__le32 txq_idx;
+	u32 tid;
+	u32 txq_idx;
 	__le32 reserved[13];
 } __attribute((packed));
 
@@ -894,8 +894,8 @@ struct ob_mac_tso_iocb_req {
 #define OB_MAC_TSO_IOCB_V	0x04
 	__le32 reserved1[2];
 	__le32 frame_len;
-	__le32 tid;
-	__le32 txq_idx;
+	u32 tid;
+	u32 txq_idx;
 	__le16 total_hdrs_len;
 	__le16 net_trans_offset;
 #define OB_MAC_TRANSPORT_HDR_SHIFT 6
@@ -916,8 +916,8 @@ struct ob_mac_tso_iocb_rsp {
 	u8 flags2;		/* */
 	u8 flags3;		/* */
 #define OB_MAC_TSO_IOCB_RSP_B	0x8000
-	__le32 tid;
-	__le32 txq_idx;
+	u32 tid;
+	u32 txq_idx;
 	__le32 reserved2[13];
 } __attribute((packed));
 
@@ -1118,7 +1118,7 @@ struct map_list {
 struct tx_ring_desc {
 	struct sk_buff *skb;
 	struct ob_mac_iocb_req *queue_entry;
-	int index;
+	u32 index;
 	struct oal oal;
 	struct map_list map[MAX_SKB_FRAGS + 1];
 	int map_cnt;
@@ -1131,7 +1131,7 @@ struct bq_desc {
 		struct sk_buff *skb;
 	} p;
 	__le64 *addr;
-	int index;
+	u32 index;
 	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
 	 DECLARE_PCI_UNMAP_LEN(maplen);
 };
-- 
1.6.0

