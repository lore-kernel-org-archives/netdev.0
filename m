From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 03/19] bna: replace pragma(pack) with attribute __packed
Date: Wed, 10 Jun 2015 18:43:09 +0200
Message-ID: <1433954605-22813-4-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbbFJQnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:02 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |   6 +-
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |  14 +--
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   6 +-
 drivers/net/ethernet/brocade/bna/bfi.h             |  70 +++++++-------
 drivers/net/ethernet/brocade/bna/bfi_cna.h         |  30 +++---
 drivers/net/ethernet/brocade/bna/bfi_enet.h        | 104 ++++++++++-----------
 6 files changed, 103 insertions(+), 127 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index f55887b..6827d91 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -187,8 +187,6 @@ enum {
 #define BFA_MFG_SUPPLIER_SERIALNUM_SIZE		20
 #define BFA_MFG_SUPPLIER_REVISION_SIZE		4
 
-#pragma pack(1)
-
 /* BFA adapter manufacturing block definition.
  *
  * All numerical fields are in big-endian format.
@@ -227,9 +225,7 @@ struct bfa_mfg_block {
 	char	initial_mode[8]; /* initial mode: hba/cna/nic */
 	u8	rsv4[84];
 	u8	md5_chksum[BFA_MFG_CHKSUM_SIZE]; /* md5 checksum */
-};
-
-#pragma pack()
+} __packed;
 
 /* ---------------------- pci definitions ------------ */
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
index ce0b228..f048887 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
@@ -109,8 +109,6 @@ union bfa_port_stats_u {
 	struct bfa_port_eth_stats eth;
 };
 
-#pragma pack(1)
-
 #define BFA_CEE_LLDP_MAX_STRING_LEN (128)
 #define BFA_CEE_DCBX_MAX_PRIORITY	(8)
 #define BFA_CEE_DCBX_MAX_PGID		(8)
@@ -133,7 +131,7 @@ struct bfa_cee_lldp_str {
 	u8 len;
 	u8 rsvd[2];
 	u8 value[BFA_CEE_LLDP_MAX_STRING_LEN];
-};
+} __packed;
 
 /* LLDP parameters */
 struct bfa_cee_lldp_cfg {
@@ -145,7 +143,7 @@ struct bfa_cee_lldp_cfg {
 	struct bfa_cee_lldp_str mgmt_addr;
 	u16 time_to_live;
 	u16 enabled_system_cap;
-};
+} __packed;
 
 enum bfa_cee_dcbx_version {
 	DCBX_PROTOCOL_PRECEE	= 1,
@@ -171,7 +169,7 @@ struct bfa_cee_dcbx_cfg {
 	u8 lls_fcoe; /* FCoE Logical Link Status */
 	u8 lls_lan; /* LAN Logical Link Status */
 	u8 rsvd[2];
-};
+} __packed;
 
 /* CEE status */
 /* Making this to tri-state for the benefit of port list command */
@@ -192,7 +190,7 @@ struct bfa_cee_attr {
 	u8 link_speed;
 	u8 nw_priority;
 	u8 filler[2];
-};
+} __packed;
 
 /* LLDP/DCBX/CEE Statistics */
 struct bfa_cee_stats {
@@ -214,8 +212,6 @@ struct bfa_cee_stats {
 	u32	cee_status_up;		/*!< CEE status up */
 	u32	cee_hw_cfg_changed;	/*!< CEE hw cfg changed */
 	u32	cee_rx_invalid_cfg;	/*!< CEE invalid cfg */
-};
-
-#pragma pack()
+} __packed;
 
 #endif	/* __BFA_DEFS_CNA_H__ */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 7a45cd0..679a503 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -59,8 +59,6 @@ enum {
 	BFA_MFG_TYPE_INVALID = 0,	 /*!< Invalid card type		*/
 };
 
-#pragma pack(1)
-
 /* Check if Mezz card */
 #define bfa_mfg_is_mezz(type) (( \
 	(type) == BFA_MFG_TYPE_JAYHAWK || \
@@ -148,8 +146,6 @@ struct bfa_mfg_vpd {
 	u8	len;		/*!< vpd data length excluding header */
 	u8	rsv;
 	u8		data[BFA_MFG_VPD_LEN];	/*!< vpd data */
-};
-
-#pragma pack()
+} __packed;
 
 #endif /* __BFA_DEFS_MFG_H__ */
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 63645ac..3e97077 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -21,8 +21,6 @@
 
 #include "bfa_defs.h"
 
-#pragma pack(1)
-
 /* BFI FW image type */
 #define	BFI_FLASH_CHUNK_SZ			256	/*!< Flash chunk size */
 #define	BFI_FLASH_CHUNK_SZ_WORDS	(BFI_FLASH_CHUNK_SZ/sizeof(u32))
@@ -36,10 +34,10 @@ struct bfi_mhdr {
 		struct {
 			u8	qid;
 			u8	fn_lpu;	/*!< msg destination		    */
-		} h2i;
+		} __packed h2i;
 		u16	i2htok;	/*!< token in msgs to host	    */
-	} mtag;
-};
+	} __packed mtag;
+} __packed;
 
 #define bfi_fn_lpu(__fn, __lpu)	((__fn) << 1 | (__lpu))
 #define bfi_mhdr_2_fn(_mh)	((_mh)->mtag.h2i.fn_lpu >> 1)
@@ -75,14 +73,14 @@ union bfi_addr_u {
 	struct {
 		u32	addr_lo;
 		u32	addr_hi;
-	} a32;
-};
+	} __packed a32;
+} __packed;
 
 /* Generic DMA addr-len pair. */
 struct bfi_alen {
 	union bfi_addr_u	al_addr;	/* DMA addr of buffer	*/
 	u32			al_len;		/* length of buffer */
-};
+} __packed;
 
 /*
  * Large Message structure - 128 Bytes size Msgs
@@ -96,7 +94,7 @@ struct bfi_alen {
 struct bfi_mbmsg {
 	struct bfi_mhdr mh;
 	u32		pl[BFI_MBMSG_SZ];
-};
+} __packed;
 
 /* Supported PCI function class codes (personality) */
 enum bfi_pcifn_class {
@@ -184,7 +182,7 @@ enum bfi_ioc_i2h_msgs {
 struct bfi_ioc_getattr_req {
 	struct bfi_mhdr mh;
 	union bfi_addr_u	attr_addr;
-};
+} __packed;
 
 struct bfi_ioc_attr {
 	u64		mfg_pwwn;	/*!< Mfg port wwn	   */
@@ -211,14 +209,14 @@ struct bfi_ioc_attr {
 	char		optrom_version[BFA_VERSION_LEN];
 	struct bfa_mfg_vpd vpd;
 	u32	card_type;	/*!< card type			*/
-};
+} __packed;
 
 /* BFI_IOC_I2H_GETATTR_REPLY message */
 struct bfi_ioc_getattr_reply {
 	struct bfi_mhdr mh;	/*!< Common msg header		*/
 	u8			status;	/*!< cfg reply status		*/
 	u8			rsvd[3];
-};
+} __packed;
 
 /* Firmware memory page offsets */
 #define BFI_IOC_SMEM_PG0_CB	(0x40)
@@ -256,7 +254,7 @@ struct bfi_ioc_fwver {
 	u8 build;
 	u8 rsvd[2];
 #endif
-};
+} __packed;
 
 struct bfi_ioc_image_hdr {
 	u32	signature;	/*!< constant signature */
@@ -269,7 +267,7 @@ struct bfi_ioc_image_hdr {
 	u32	rsvd_b[2];
 	struct bfi_ioc_fwver fwver;
 	u32	md5sum[BFI_IOC_MD5SUM_SZ];
-};
+} __packed;
 
 enum bfi_ioc_img_ver_cmp {
 	BFI_IOC_IMG_VER_INCOMP,
@@ -301,7 +299,7 @@ enum bfi_port_mode {
 struct bfi_ioc_hbeat {
 	struct bfi_mhdr mh;		/*!< common msg header		*/
 	u32	   hb_count;	/*!< current heart beat count	*/
-};
+} __packed;
 
 /* IOC hardware/firmware state */
 enum bfi_ioc_state {
@@ -353,7 +351,7 @@ struct bfi_ioc_ctrl_req {
 	u16			clscode;
 	u16			rsvd;
 	u32		tv_sec;
-};
+} __packed;
 
 /* BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages */
 struct bfi_ioc_ctrl_reply {
@@ -362,7 +360,7 @@ struct bfi_ioc_ctrl_reply {
 	u8			port_mode;	/*!< enum bfa_mode */
 	u8			cap_bm;		/*!< capability bit mask */
 	u8			rsvd;
-};
+} __packed;
 
 #define BFI_IOC_MSGSZ   8
 /* H2I Messages */
@@ -372,14 +370,14 @@ union bfi_ioc_h2i_msg_u {
 	struct bfi_ioc_ctrl_req disable_req;
 	struct bfi_ioc_getattr_req getattr_req;
 	u32			mboxmsg[BFI_IOC_MSGSZ];
-};
+} __packed;
 
 /* I2H Messages */
 union bfi_ioc_i2h_msg_u {
 	struct bfi_mhdr mh;
 	struct bfi_ioc_ctrl_reply fw_event;
 	u32			mboxmsg[BFI_IOC_MSGSZ];
-};
+} __packed;
 
 /*----------------------------------------------------------------------
  *				MSGQ
@@ -408,7 +406,7 @@ struct bfi_msgq_mhdr {
 	u16	num_entries;
 	u8	enet_id;
 	u8	rsvd[1];
-};
+} __packed;
 
 #define bfi_msgq_mhdr_set(_mh, _mc, _mid, _tok, _enet_id) do {	\
 	(_mh).msg_class	 = (_mc);	\
@@ -430,21 +428,21 @@ struct bfi_msgq {
 	union bfi_addr_u addr;
 	u16 q_depth;     /* Total num of entries in the queue */
 	u8 rsvd[2];
-};
+} __packed;
 
 /* BFI_ENET_MSGQ_CFG_REQ TBD init or cfg? */
 struct bfi_msgq_cfg_req {
 	struct bfi_mhdr mh;
 	struct bfi_msgq cmdq;
 	struct bfi_msgq rspq;
-};
+} __packed;
 
 /* BFI_ENET_MSGQ_CFG_RSP */
 struct bfi_msgq_cfg_rsp {
 	struct bfi_mhdr mh;
 	u8 cmd_status;
 	u8 rsvd[3];
-};
+} __packed;
 
 /* BFI_MSGQ_H2I_DOORBELL */
 struct bfi_msgq_h2i_db {
@@ -452,8 +450,8 @@ struct bfi_msgq_h2i_db {
 	union {
 		u16 cmdq_pi;
 		u16 rspq_ci;
-	} idx;
-};
+	} __packed idx;
+} __packed;
 
 /* BFI_MSGQ_I2H_DOORBELL */
 struct bfi_msgq_i2h_db {
@@ -461,8 +459,8 @@ struct bfi_msgq_i2h_db {
 	union {
 		u16 rspq_pi;
 		u16 cmdq_ci;
-	} idx;
-};
+	} __packed idx;
+} __packed;
 
 #define BFI_CMD_COPY_SZ 28
 
@@ -470,14 +468,14 @@ struct bfi_msgq_i2h_db {
 struct bfi_msgq_h2i_cmdq_copy_rsp {
 	struct bfi_mhdr mh;
 	u8	      data[BFI_CMD_COPY_SZ];
-};
+} __packed;
 
 /* BFI_MSGQ_I2H_CMD_COPY_REQ */
 struct bfi_msgq_i2h_cmdq_copy_req {
 	struct bfi_mhdr mh;
 	u16     offset;
 	u16     len;
-};
+} __packed;
 
 /*
  *      FLASH module specific
@@ -505,7 +503,7 @@ enum bfi_flash_i2h_msgs {
 struct bfi_flash_query_req {
 	struct bfi_mhdr mh;   /* Common msg header */
 	struct bfi_alen alen;
-};
+} __packed;
 
 /*
  * Flash write request
@@ -519,7 +517,7 @@ struct bfi_flash_write_req {
 	u8	rsv[2];
 	u32	offset;
 	u32	length;
-};
+} __packed;
 
 /*
  * Flash read request
@@ -532,7 +530,7 @@ struct bfi_flash_read_req {
 	u32	offset;
 	u32	length;
 	struct bfi_alen alen;
-};
+} __packed;
 
 /*
  * Flash query response
@@ -540,7 +538,7 @@ struct bfi_flash_read_req {
 struct bfi_flash_query_rsp {
 	struct bfi_mhdr mh;	/* Common msg header */
 	u32	status;
-};
+} __packed;
 
 /*
  * Flash read response
@@ -552,7 +550,7 @@ struct bfi_flash_read_rsp {
 	u8	rsv[3];
 	u32	status;
 	u32	length;
-};
+} __packed;
 
 /*
  * Flash write response
@@ -564,8 +562,6 @@ struct bfi_flash_write_rsp {
 	u8	rsv[3];
 	u32	status;
 	u32	length;
-};
-
-#pragma pack()
+} __packed;
 
 #endif /* __BFI_H__ */
diff --git a/drivers/net/ethernet/brocade/bna/bfi_cna.h b/drivers/net/ethernet/brocade/bna/bfi_cna.h
index bd605be..fad6511 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_cna.h
@@ -22,8 +22,6 @@
 #include "bfi.h"
 #include "bfa_defs_cna.h"
 
-#pragma pack(1)
-
 enum bfi_port_h2i {
 	BFI_PORT_H2I_ENABLE_REQ		= (1),
 	BFI_PORT_H2I_DISABLE_REQ	= (2),
@@ -43,7 +41,7 @@ struct bfi_port_generic_req {
 	struct bfi_mhdr mh;		/*!< msg header			    */
 	u32	msgtag;		/*!< msgtag for reply		    */
 	u32	rsvd;
-};
+} __packed;
 
 /* Generic RSP type */
 struct bfi_port_generic_rsp {
@@ -51,13 +49,13 @@ struct bfi_port_generic_rsp {
 	u8		status;		/*!< port enable status		    */
 	u8		rsvd[3];
 	u32	msgtag;		/*!< msgtag for reply		    */
-};
+} __packed;
 
 /* BFI_PORT_H2I_GET_STATS_REQ */
 struct bfi_port_get_stats_req {
 	struct bfi_mhdr mh;		/*!< common msg header		    */
 	union bfi_addr_u   dma_addr;
-};
+} __packed;
 
 union bfi_port_h2i_msg_u {
 	struct bfi_mhdr mh;
@@ -65,7 +63,7 @@ union bfi_port_h2i_msg_u {
 	struct bfi_port_generic_req disable_req;
 	struct bfi_port_get_stats_req getstats_req;
 	struct bfi_port_generic_req clearstats_req;
-};
+} __packed;
 
 union bfi_port_i2h_msg_u {
 	struct bfi_mhdr mh;
@@ -73,7 +71,7 @@ union bfi_port_i2h_msg_u {
 	struct bfi_port_generic_rsp disable_rsp;
 	struct bfi_port_generic_rsp getstats_rsp;
 	struct bfi_port_generic_rsp clearstats_rsp;
-};
+} __packed;
 
 /* @brief Mailbox commands from host to (DCBX/LLDP) firmware */
 enum bfi_cee_h2i_msgs {
@@ -97,7 +95,7 @@ enum bfi_cee_i2h_msgs {
  */
 struct bfi_lldp_reset_stats {
 	struct bfi_mhdr mh;
-};
+} __packed;
 
 /*
  * @brief H2I command structure for resetting the stats.
@@ -105,7 +103,7 @@ struct bfi_lldp_reset_stats {
  */
 struct bfi_cee_reset_stats {
 	struct bfi_mhdr mh;
-};
+} __packed;
 
 /*
  * @brief  get configuration  command from host
@@ -114,7 +112,7 @@ struct bfi_cee_reset_stats {
 struct bfi_cee_get_req {
 	struct bfi_mhdr mh;
 	union bfi_addr_u   dma_addr;
-};
+} __packed;
 
 /*
  * @brief reply message from firmware
@@ -124,7 +122,7 @@ struct bfi_cee_get_rsp {
 	struct bfi_mhdr mh;
 	u8			cmd_status;
 	u8			rsvd[3];
-};
+} __packed;
 
 /*
  * @brief  get configuration  command from host
@@ -133,7 +131,7 @@ struct bfi_cee_get_rsp {
 struct bfi_cee_stats_req {
 	struct bfi_mhdr mh;
 	union bfi_addr_u   dma_addr;
-};
+} __packed;
 
 /*
  * @brief reply message from firmware
@@ -143,22 +141,20 @@ struct bfi_cee_stats_rsp {
 	struct bfi_mhdr mh;
 	u8			cmd_status;
 	u8			rsvd[3];
-};
+} __packed;
 
 /* @brief mailbox command structures from host to firmware */
 union bfi_cee_h2i_msg_u {
 	struct bfi_mhdr mh;
 	struct bfi_cee_get_req get_req;
 	struct bfi_cee_stats_req stats_req;
-};
+} __packed;
 
 /* @brief mailbox message structures from firmware to host	*/
 union bfi_cee_i2h_msg_u {
 	struct bfi_mhdr mh;
 	struct bfi_cee_get_rsp get_rsp;
 	struct bfi_cee_stats_rsp stats_rsp;
-};
-
-#pragma pack()
+} __packed;
 
 #endif /* __BFI_CNA_H__ */
diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index 5b0c6c8..fad3a12 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -36,8 +36,6 @@
 #include "bfa_defs.h"
 #include "bfi.h"
 
-#pragma pack(1)
-
 #define BFI_ENET_CFG_MAX		32	/* Max resources per PF */
 
 #define BFI_ENET_TXQ_PRIO_MAX		8
@@ -59,8 +57,8 @@ union bfi_addr_be_u {
 	struct {
 		u32	addr_hi;	/* Most Significant 32-bits */
 		u32	addr_lo;	/* Least Significant 32-Bits */
-	} a32;
-};
+	} __packed a32;
+} __packed;
 
 /*	T X   Q U E U E   D E F I N E S      */
 /* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
@@ -88,28 +86,28 @@ struct bfi_enet_txq_wi_base {
 	u16			vlan_tag;
 	u16			lso_mss;	/* Only 14 LSB are valid */
 	u32			frame_length;	/* Only 24 LSB are valid */
-};
+} __packed;
 
 struct bfi_enet_txq_wi_ext {
 	u16			reserved;
 	u16			opcode;		/* BFI_ENET_TXQ_WI_EXTENSION */
 	u32			reserved2[3];
-};
+} __packed;
 
 struct bfi_enet_txq_wi_vector {			/* Tx Buffer Descriptor */
 	u16			reserved;
 	u16			length;		/* Only 14 LSB are valid */
 	union bfi_addr_be_u	addr;
-};
+} __packed;
 
 /*  TxQ Entry Structure  */
 struct bfi_enet_txq_entry {
 	union {
 		struct bfi_enet_txq_wi_base	base;
 		struct bfi_enet_txq_wi_ext	ext;
-	} wi;
+	} __packed wi;
 	struct bfi_enet_txq_wi_vector vector[BFI_ENET_TXQ_WI_VECT_MAX];
-};
+} __packed;
 
 #define wi_hdr		wi.base
 #define wi_ext_hdr	wi.ext
@@ -120,7 +118,7 @@ struct bfi_enet_txq_entry {
 /*   R X   Q U E U E   D E F I N E S   */
 struct bfi_enet_rxq_entry {
 	union bfi_addr_be_u  rx_buffer;
-};
+} __packed;
 
 /*   R X   C O M P L E T I O N   Q U E U E   D E F I N E S   */
 /* CQ Entry Flags */
@@ -161,7 +159,7 @@ struct bfi_enet_cq_entry {
 	u8	reserved1;
 	u8	reserved2;
 	u8	rxq_id;
-};
+} __packed;
 
 /*   E N E T   C O N T R O L   P A T H   C O M M A N D S   */
 struct bfi_enet_q {
@@ -169,23 +167,23 @@ struct bfi_enet_q {
 	union bfi_addr_u	first_entry;
 	u16		pages;	/* # of pages */
 	u16		page_sz;
-};
+} __packed;
 
 struct bfi_enet_txq {
 	struct bfi_enet_q	q;
 	u8			priority;
 	u8			rsvd[3];
-};
+} __packed;
 
 struct bfi_enet_rxq {
 	struct bfi_enet_q	q;
 	u16		rx_buffer_size;
 	u16		rsvd;
-};
+} __packed;
 
 struct bfi_enet_cq {
 	struct bfi_enet_q	q;
-};
+} __packed;
 
 struct bfi_enet_ib_cfg {
 	u8		int_pkt_dma;
@@ -198,16 +196,16 @@ struct bfi_enet_ib_cfg {
 	u32	inter_pkt_timeout;
 	u8		inter_pkt_count;
 	u8		rsvd1[3];
-};
+} __packed;
 
 struct bfi_enet_ib {
 	union bfi_addr_u	index_addr;
 	union {
 		u16	msix_index;
 		u16	intx_bitmask;
-	} intr;
+	} __packed intr;
 	u16		rsvd;
-};
+} __packed;
 
 /* ENET command messages */
 enum bfi_enet_h2i_msgs {
@@ -355,7 +353,7 @@ enum bfi_enet_err {
  */
 struct bfi_enet_req {
 	struct bfi_msgq_mhdr mh;
-};
+} __packed;
 
 /* Enable/Disable Request
  *
@@ -370,7 +368,7 @@ struct bfi_enet_enable_req {
 	struct		bfi_msgq_mhdr mh;
 	u8		enable;		/* 1 = enable;  0 = disable */
 	u8		rsvd[3];
-};
+} __packed;
 
 /* Generic Response */
 struct bfi_enet_rsp {
@@ -378,7 +376,7 @@ struct bfi_enet_rsp {
 	u8		error;		/*!< if error see cmd_offset */
 	u8		rsvd;
 	u16		cmd_offset;	/*!< offset to invalid parameter */
-};
+} __packed;
 
 /* GLOBAL CONFIGURATION */
 
@@ -387,7 +385,7 @@ struct bfi_enet_rsp {
  */
 struct bfi_enet_attr_req {
 	struct bfi_msgq_mhdr	mh;
-};
+} __packed;
 
 /* bfi_enet_attr_rsp is used by:
  *	BFI_ENET_I2H_GET_ATTR_RSP
@@ -400,7 +398,7 @@ struct bfi_enet_attr_rsp {
 	u32		max_cfg;
 	u32		max_ucmac;
 	u32		rit_size;
-};
+} __packed;
 
 /* Tx Configuration
  *
@@ -421,7 +419,7 @@ struct bfi_enet_tx_cfg {
 	u8		apply_vlan_filter;
 	u8		add_to_vswitch;
 	u8		rsvd1[1];
-};
+} __packed;
 
 struct bfi_enet_tx_cfg_req {
 	struct bfi_msgq_mhdr mh;
@@ -431,7 +429,7 @@ struct bfi_enet_tx_cfg_req {
 	struct {
 		struct bfi_enet_txq	q;
 		struct bfi_enet_ib	ib;
-	} q_cfg[BFI_ENET_TXQ_PRIO_MAX];
+	} __packed q_cfg[BFI_ENET_TXQ_PRIO_MAX];
 
 	struct bfi_enet_ib_cfg	ib_cfg;
 
@@ -448,7 +446,7 @@ struct bfi_enet_tx_cfg_rsp {
 		u32	i_dbell;	/* PCI base address offset */
 		u8	hw_qid;		/* For debugging */
 		u8	rsvd[3];
-	} q_handles[BFI_ENET_TXQ_PRIO_MAX];
+	} __packed q_handles[BFI_ENET_TXQ_PRIO_MAX];
 };
 
 /* Rx Configuration
@@ -481,13 +479,13 @@ struct bfi_enet_rx_cfg {
 		u8			force_offset;
 		u8			type;
 		u8			rsvd1;
-	} hds;
+	} __packed hds;
 
 	u8		multi_buffer;
 	u8		strip_vlan;
 	u8		drop_untagged;
 	u8		rsvd2;
-};
+} __packed;
 
 /*
  * Multicast frames are received on the ql of q-set index zero.
@@ -504,12 +502,12 @@ struct bfi_enet_rx_cfg_req {
 		struct bfi_enet_rxq	qs;	/* small/header buffers */
 		struct bfi_enet_cq	cq;
 		struct bfi_enet_ib	ib;
-	} q_cfg[BFI_ENET_RX_QSET_MAX];
+	} __packed q_cfg[BFI_ENET_RX_QSET_MAX];
 
 	struct bfi_enet_ib_cfg	ib_cfg;
 
 	struct bfi_enet_rx_cfg	rx_cfg;
-};
+} __packed;
 
 struct bfi_enet_rx_cfg_rsp {
 	struct bfi_msgq_mhdr mh;
@@ -524,8 +522,8 @@ struct bfi_enet_rx_cfg_rsp {
 		u8		hw_sqid;  /* For debugging */
 		u8		hw_cqid;  /* For debugging */
 		u8		rsvd;
-	} q_handles[BFI_ENET_RX_QSET_MAX];
-};
+	} __packed q_handles[BFI_ENET_RX_QSET_MAX];
+} __packed;
 
 /* RIT
  *
@@ -537,7 +535,7 @@ struct bfi_enet_rit_req {
 	u16	size;			/* number of table-entries used */
 	u8	rsvd[2];
 	u8	table[BFI_ENET_RSS_RIT_MAX];
-};
+} __packed;
 
 /* RSS
  *
@@ -556,12 +554,12 @@ struct bfi_enet_rss_cfg {
 	u8	mask;
 	u8	rsvd[2];
 	u32	key[BFI_ENET_RSS_KEY_LEN];
-};
+} __packed;
 
 struct bfi_enet_rss_cfg_req {
 	struct bfi_msgq_mhdr	mh;
 	struct bfi_enet_rss_cfg	cfg;
-};
+} __packed;
 
 /* MAC Unicast
  *
@@ -575,14 +573,14 @@ struct bfi_enet_ucast_req {
 	struct bfi_msgq_mhdr	mh;
 	u8			mac_addr[ETH_ALEN];
 	u8			rsvd[2];
-};
+} __packed;
 
 /* MAC Unicast + VLAN */
 struct bfi_enet_mac_n_vlan_req {
 	struct bfi_msgq_mhdr	mh;
 	u16			vlan_id;
 	u8			mac_addr[ETH_ALEN];
-};
+} __packed;
 
 /* MAC Multicast
  *
@@ -593,7 +591,7 @@ struct bfi_enet_mcast_add_req {
 	struct bfi_msgq_mhdr	mh;
 	u8			mac_addr[ETH_ALEN];
 	u8			rsvd[2];
-};
+} __packed;
 
 /* bfi_enet_mac_mfilter_add_rsp is used by:
  *	BFI_ENET_I2H_MAC_MCAST_ADD_RSP
@@ -605,7 +603,7 @@ struct bfi_enet_mcast_add_rsp {
 	u16			cmd_offset;
 	u16			handle;
 	u8			rsvd1[2];
-};
+} __packed;
 
 /* bfi_enet_mac_mfilter_del_req is used by:
  *	BFI_ENET_H2I_MAC_MCAST_DEL_REQ
@@ -614,7 +612,7 @@ struct bfi_enet_mcast_del_req {
 	struct bfi_msgq_mhdr	mh;
 	u16			handle;
 	u8			rsvd[2];
-};
+} __packed;
 
 /* VLAN
  *
@@ -626,7 +624,7 @@ struct bfi_enet_rx_vlan_req {
 	u8			block_idx;
 	u8			rsvd[3];
 	u32			bit_mask[BFI_ENET_VLAN_WORDS_MAX];
-};
+} __packed;
 
 /* PAUSE
  *
@@ -638,7 +636,7 @@ struct bfi_enet_set_pause_req {
 	u8			rsvd[2];
 	u8			tx_pause;	/* 1 = enable;  0 = disable */
 	u8			rx_pause;	/* 1 = enable;  0 = disable */
-};
+} __packed;
 
 /* DIAGNOSTICS
  *
@@ -650,7 +648,7 @@ struct bfi_enet_diag_lb_req {
 	u8			rsvd[2];
 	u8			mode;		/* cable or Serdes */
 	u8			enable;		/* 1 = enable;  0 = disable */
-};
+} __packed;
 
 /* enum for Loopback opmodes */
 enum {
@@ -671,7 +669,7 @@ struct bfi_enet_stats_req {
 	u32			rx_enet_mask;
 	u32			tx_enet_mask;
 	union bfi_addr_u	host_buffer;
-};
+} __packed;
 
 /* defines for "stats_mask" above. */
 #define BFI_ENET_STATS_MAC    (1 << 0)    /* !< MAC Statistics */
@@ -699,7 +697,7 @@ struct bfi_enet_stats_txf {
 	u64 errors;
 	u64 filter_vlan;      /* frames filtered due to VLAN */
 	u64 filter_mac_sa;    /* frames filtered due to SA check */
-};
+} __packed;
 
 /* RxF Frame Statistics */
 struct bfi_enet_stats_rxf {
@@ -715,7 +713,7 @@ struct bfi_enet_stats_rxf {
 	u64 bcast;
 	u64 bcast_vlan;
 	u64 frame_drops;
-};
+} __packed;
 
 /* FC Tx Frame Statistics */
 struct bfi_enet_stats_fc_tx {
@@ -734,7 +732,7 @@ struct bfi_enet_stats_fc_tx {
 	u64 txf_parity_errors;
 	u64 txf_timeout;
 	u64 txf_fid_parity_errors;
-};
+} __packed;
 
 /* FC Rx Frame Statistics */
 struct bfi_enet_stats_fc_rx {
@@ -749,7 +747,7 @@ struct bfi_enet_stats_fc_rx {
 	u64 rxf_bcast_octets;
 	u64 rxf_bcast;
 	u64 rxf_bcast_vlan;
-};
+} __packed;
 
 /* RAD Frame Statistics */
 struct bfi_enet_stats_rad {
@@ -770,7 +768,7 @@ struct bfi_enet_stats_rad {
 	u64 rx_bcast_vlan;
 
 	u64 rx_drops;
-};
+} __packed;
 
 /* BPC Tx Registers */
 struct bfi_enet_stats_bpc {
@@ -785,7 +783,7 @@ struct bfi_enet_stats_bpc {
 	u64 rx_zero_pause[8];	/*!< Pause cancellation */
 	/*!<Pause initiation rather than retention */
 	u64 rx_first_pause[8];
-};
+} __packed;
 
 /* MAC Rx Statistics */
 struct bfi_enet_stats_mac {
@@ -838,7 +836,7 @@ struct bfi_enet_stats_mac {
 	u64 tx_oversize;
 	u64 tx_undersize;
 	u64 tx_fragments;
-};
+} __packed;
 
 /* Complete statistics, DMAed from fw to host followed by
  * BFI_ENET_I2H_STATS_GET_RSP
@@ -852,8 +850,6 @@ struct bfi_enet_stats {
 	struct bfi_enet_stats_fc_tx	fc_tx_stats;
 	struct bfi_enet_stats_rxf	rxf_stats[BFI_ENET_CFG_MAX];
 	struct bfi_enet_stats_txf	txf_stats[BFI_ENET_CFG_MAX];
-};
-
-#pragma pack()
+} __packed;
 
 #endif  /* __BFI_ENET_H__ */
-- 
2.3.6
