From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qla3xxx: cleanup: Remove some unused structure definitions and structure elements.
Date: Thu, 31 Jul 2008 13:46:07 -0700
Message-ID: <12175371684132-git-send-email-ron.mercer@qlogic.com>
References: <20080731204514.GA5457@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23911 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbYGaUqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 16:46:11 -0400
In-Reply-To: <20080731204514.GA5457@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    4 --
 drivers/net/qla3xxx.h |   97 -------------------------------------------------
 2 files changed, 0 insertions(+), 101 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 155eb52..5821112 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3495,8 +3495,6 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
 	case ISP_CONTROL_FN0_NET:
 		qdev->mac_index = 0;
 		qdev->mac_ob_opcode = OUTBOUND_MAC_IOCB | func_number;
-		qdev->tcp_ob_opcode = OUTBOUND_TCP_IOCB | func_number;
-		qdev->update_ob_opcode = UPDATE_NCB_IOCB | func_number;
 		qdev->mb_bit_mask = FN0_MA_BITS_MASK;
 		qdev->PHYAddr = PORT0_PHY_ADDRESS;
 		if (port_status & PORT_STATUS_SM0)
@@ -3508,8 +3506,6 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
 	case ISP_CONTROL_FN1_NET:
 		qdev->mac_index = 1;
 		qdev->mac_ob_opcode = OUTBOUND_MAC_IOCB | func_number;
-		qdev->tcp_ob_opcode = OUTBOUND_TCP_IOCB | func_number;
-		qdev->update_ob_opcode = UPDATE_NCB_IOCB | func_number;
 		qdev->mb_bit_mask = FN1_MA_BITS_MASK;
 		qdev->PHYAddr = PORT1_PHY_ADDRESS;
 		if (port_status & PORT_STATUS_SM1)
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index e0655f9..7113e71 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -22,8 +22,6 @@
 
 #define OPCODE_FUNC_ID_MASK                 0x30
 #define OUTBOUND_MAC_IOCB                   0x01	/* plus function bits */
-#define OUTBOUND_TCP_IOCB                   0x03	/* plus function bits */
-#define UPDATE_NCB_IOCB                     0x00	/* plus function bits */
 
 #define FN0_MA_BITS_MASK    0x00
 #define FN1_MA_BITS_MASK    0x80
@@ -151,75 +149,6 @@ struct ob_ip_iocb_rsp {
 	__le32 reserved2;
 };
 
-struct ob_tcp_iocb_req {
-	u8 opcode;
-
-	u8 flags0;
-#define OB_TCP_IOCB_REQ_P       0x80
-#define OB_TCP_IOCB_REQ_CI      0x20
-#define OB_TCP_IOCB_REQ_H       0x10
-#define OB_TCP_IOCB_REQ_LN      0x08
-#define OB_TCP_IOCB_REQ_K       0x04
-#define OB_TCP_IOCB_REQ_D       0x02
-#define OB_TCP_IOCB_REQ_I       0x01
-
-	u8 flags1;
-#define OB_TCP_IOCB_REQ_OSM     0x40
-#define OB_TCP_IOCB_REQ_URG     0x20
-#define OB_TCP_IOCB_REQ_ACK     0x10
-#define OB_TCP_IOCB_REQ_PSH     0x08
-#define OB_TCP_IOCB_REQ_RST     0x04
-#define OB_TCP_IOCB_REQ_SYN     0x02
-#define OB_TCP_IOCB_REQ_FIN     0x01
-
-	u8 options_len;
-#define OB_TCP_IOCB_REQ_OMASK   0xF0
-#define OB_TCP_IOCB_REQ_SHIFT   4
-
-	__le32 transaction_id;
-	__le32 data_len;
-	__le32 hncb_ptr_low;
-	__le32 hncb_ptr_high;
-	__le32 buf_addr0_low;
-	__le32 buf_addr0_high;
-	__le32 buf_0_len;
-	__le32 buf_addr1_low;
-	__le32 buf_addr1_high;
-	__le32 buf_1_len;
-	__le32 buf_addr2_low;
-	__le32 buf_addr2_high;
-	__le32 buf_2_len;
-	__le32 time_stamp;
-	__le32 reserved1;
-};
-
-struct ob_tcp_iocb_rsp {
-	u8 opcode;
-
-	u8 flags0;
-#define OB_TCP_IOCB_RSP_C       0x20
-#define OB_TCP_IOCB_RSP_H       0x10
-#define OB_TCP_IOCB_RSP_LN      0x08
-#define OB_TCP_IOCB_RSP_K       0x04
-#define OB_TCP_IOCB_RSP_D       0x02
-#define OB_TCP_IOCB_RSP_I       0x01
-
-	u8 flags1;
-#define OB_TCP_IOCB_RSP_E       0x10
-#define OB_TCP_IOCB_RSP_W       0x08
-#define OB_TCP_IOCB_RSP_P       0x04
-#define OB_TCP_IOCB_RSP_T       0x02
-#define OB_TCP_IOCB_RSP_F       0x01
-
-	u8 state;
-#define OB_TCP_IOCB_RSP_SMASK   0xF0
-#define OB_TCP_IOCB_RSP_SHIFT   4
-
-	__le32 transaction_id;
-	__le32 local_ncb_ptr;
-	__le32 reserved0;
-};
-
 struct ib_ip_iocb_rsp {
 	u8 opcode;
 #define IB_IP_IOCB_RSP_3032_V   0x80
@@ -248,25 +177,6 @@ struct ib_ip_iocb_rsp {
 	__le32 ial_high;
 };
 
-struct ib_tcp_iocb_rsp {
-	u8 opcode;
-	u8 flags;
-#define IB_TCP_IOCB_RSP_P       0x80
-#define IB_TCP_IOCB_RSP_T       0x40
-#define IB_TCP_IOCB_RSP_D       0x20
-#define IB_TCP_IOCB_RSP_N       0x10
-#define IB_TCP_IOCB_RSP_IP      0x03
-#define IB_TCP_FLAG_MASK        0xf0
-#define IB_TCP_FLAG_IOCB_SYN    0x00
-
-#define TCP_IB_RSP_FLAGS(x) (x->flags & ~IB_TCP_FLAG_MASK)
-
-	__le16 length;
-	__le32 hncb_ref_num;
-	__le32 ial_low;
-	__le32 ial_high;
-};
-
 struct net_rsp_iocb {
 	u8 opcode;
 	u8 flags;
@@ -1258,20 +1168,13 @@ struct ql3_adapter {
 	u32 small_buf_release_cnt;
 	u32 small_buf_total_size;
 
-	/* ISR related, saves status for DPC. */
-	u32 control_status;
-
 	struct eeprom_data nvram_data;
-	struct timer_list ioctl_timer;
 	u32 port_link_state;
-	u32 last_rsp_offset;
 
 	/* 4022 specific */
 	u32 mac_index;		/* Driver's MAC number can be 0 or 1 for first and second networking functions respectively */
 	u32 PHYAddr;		/* Address of PHY 0x1e00 Port 0 and 0x1f00 Port 1 */
 	u32 mac_ob_opcode;	/* Opcode to use on mac transmission */
-	u32 tcp_ob_opcode;	/* Opcode to use on tcp transmission */
-	u32 update_ob_opcode;	/* Opcode to use for updating NCB */
 	u32 mb_bit_mask;	/* MA Bits mask to use on transmission */
 	u32 numPorts;
 	struct workqueue_struct *workqueue;
-- 
1.5.0.rc4.16.g9e258

