From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 11/12] benet: f/w header files
Date: Thu, 12 Jun 2008 03:58:29 -0700
Message-ID: <20080612105829.6a03a909@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:38822 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759666AbYFLK6c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/fw/be_gen_id_ranges.h       |  217 ++++++
 drivers/message/beclib/fw/bmap/be_common_bmap.h    |   56 ++
 drivers/message/beclib/fw/bmap/fwcmd_common_bmap.h |  691 ++++++++++++++++++++
 drivers/message/beclib/fw/bmap/fwcmd_eth_bmap.h    |  309 +++++++++
 drivers/message/beclib/fw/bmap/fwcmd_hdr_bmap.h    |   54 ++
 drivers/message/beclib/fw/bmap/fwcmd_top_bmap.h    |   26 +
 drivers/message/beclib/fw/bmap/fwcmd_types_bmap.h  |   29 +
 7 files changed, 1382 insertions(+), 0 deletions(-)
 create mode 100755 drivers/message/beclib/fw/be_gen_id_ranges.h
 create mode 100644 drivers/message/beclib/fw/bmap/be_common_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/fwcmd_common_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/fwcmd_eth_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/fwcmd_hdr_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/fwcmd_top_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/fwcmd_types_bmap.h

diff --git a/drivers/message/beclib/fw/be_gen_id_ranges.h b/drivers/message/beclib/fw/be_gen_id_ranges.h
new file mode 100755
index 0000000..6413872
--- /dev/null
+++ b/drivers/message/beclib/fw/be_gen_id_ranges.h
@@ -0,0 +1,217 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+@file
+    be_gen_id_ranges.h
+
+@brief
+    Provides ID ranges and conversion macros between the types of ID numbers.
+
+*/
+#ifndef __be_gen_id_ranges_h__
+#define __be_gen_id_ranges_h__
+
+#ifndef BE_CONFIG
+#pragma message("WARNING: configuration not defined. Assuming BE_CONFIG=0"
+		" by default.")
+#define BE_CONFIG 0
+#endif
+
+/*/////////////////////////////////////////////////////////////////////// */
+/*
+ * For each BE_CONFIG value, define the CID ranges for the ULP protocol
+ * firmware.
+ *
+ * The BE_CONFIG definitions must match the description of the
+ * configuration under the fw\config\readme.txt file.
+ * The MAX_* literals must all be multiples of 32!!! This is an implementation
+ * restriction in the software that makes use of these literals for bitvector
+ * classes. Having a non-32 multiple MAX_* literal will cause an compile-time
+ * assert! At some point in the future this restriction may be removed (along
+ * with this comment blurb). Note: if the desired range is not an even multiple
+ * of 32, the developer must ensure the extra/invalid bits are not used.
+ */
+/*//////////////////////////////////////////////////////////////////// */
+
+#if (BE_CONFIG == 0)
+
+/* --- CID_START_ENUM --- */
+#define ISCSI_CID_START                 (0)     /* Start of connection
+							ID range for ISCSI */
+#define DEFPDU_CID_START                (0)     /* Start of connection
+							ID range for iSCSI
+							default pdu queue */
+#define ETX_CID_START                   (1024)  /* Start of connection
+							ID range for ETX */
+#define RDMA_CID_START                  (0)     /* Start of connection
+						       ID range for RDMA */
+
+/* --- MAX_CIDS_ENUM --- */
+#define MAX_DEFPDU_CIDS                 (32)    /* Maximum number of
+						       iSCSI DEF pdu cids */
+#define MAX_ETX_CIDS                    (64)    /* Maximum number of ETX
+						       connections */
+#define MAX_ISCSI_CIDS                  (512)   /* Maximum number of
+						       ISCSI connections */
+#define MAX_ISCSI_CIDS_CT               (512)   /* Maximum number of
+						       ISCSI connections
+						       per chute */
+#define MAX_RDMA_CIDS                   (0)     /* Maximum number of
+						       RDMA connections */
+
+#elif (BE_CONFIG == 1)
+
+/* --- CID_START_ENUM --- */
+#define ISCSI_CID_START                 (0)     /* Start of connection
+						       ID range for ISCSI */
+#define DEFPDU_CID_START                (0)     /* Start of connection
+						       ID range for iSCSI
+						       default pdu queue */
+#define RDMA_CID_START                  (64)    /* Start of connection
+						       ID range for RDMA */
+#define ETX_CID_START                   (1024)  /* Start of connection
+						       ID range for ETX */
+
+/* --- MAX_CIDS_ENUM --- */
+#define MAX_DEFPDU_CIDS                 (32)    /* Maximum number of
+						       iSCSI DEF pdu cids */
+#define MAX_ISCSI_CIDS                  (64)    /* Maximum number
+						       of ISCSI connections */
+#define MAX_ISCSI_CIDS_CT               (64)    /* Maximum number
+						       of ISCSI connections
+						       per chute */
+#define MAX_ETX_CIDS                    (64)    /* Maximum number of
+						       ETX connections */
+#define MAX_RDMA_CIDS                   (512)   /* Maximum number
+						       of RDMA connections */
+
+#elif (BE_CONFIG == 2)
+
+/* --- CID_START_ENUM --- */
+#define DEFPDU_CID_START                (0)     /* Start of connection
+						       ID range for iSCSI
+						       default pdu queue */
+#define ISCSI_TGT_CID_START             (448)   /* Start of connection
+						       ID range for ISCSI */
+#define ISCSI_CID_START                 (ISCSI_TGT_CID_START)
+#define ETX_CID_START                   (1024)  /* Start of connection
+						       ID range for ETX */
+#define RDMA_CID_START                  (0)     /* Start of connection
+						       ID range for RDMA */
+
+/* --- MAX_CIDS_ENUM --- */
+#define MAX_DEFPDU_CIDS                 (32)    /* Maximum number of
+						       iSCSI DEF pdu cids */
+#define MAX_ETX_CIDS                    (64)    /* Maximum number of
+						       ETX cids */
+#define MAX_ISCSI_TGT_CIDS              (512)   /* Maximum number
+						       of ISCSI connections */
+#define MAX_ISCSI_CIDS                  (MAX_ISCSI_TGT_CIDS)
+#define MAX_ISCSI_CIDS_CT               (256)   /* Maximum number of
+						       ISCSI connections
+						       per chute */
+#define MAX_RDMA_CIDS                   (0)     /* Maximum number of
+						       RDMA connections */
+
+#elif (BE_CONFIG == 3)
+
+/* --- CID_START_ENUM --- */
+#define DEFPDU_CID_START                (0)     /* Start of connection
+						       ID range for iSCSI
+						       default pdu queue */
+#define ISCSI_TGT_CID_START             (0)     /* Start of connection
+						       ID range for ISCSI */
+#define ISCSI_CID_START                 (ISCSI_TGT_CID_START)
+#define ETX_CID_START                   (1024)  /* Start of connection
+						       ID range for ETX */
+#define RDMA_CID_START                  (1024)     /* Start of connection
+							  ID range for RDMA */
+
+/* --- MAX_CIDS_ENUM --- */
+#define MAX_DEFPDU_CIDS                 (32)    /* Maximum number
+						       of iSCSI DEF pdu cids */
+#define MAX_ETX_CIDS                    (64)    /* Maximum number
+						       of ETX cids */
+#define MAX_ISCSI_TGT_CIDS              (1024)  /* Maximum number
+						       of ISCSI connections
+						       supported. */
+#define MAX_ISCSI_CIDS                  (MAX_ISCSI_TGT_CIDS)
+#define MAX_ISCSI_CIDS_CT               (512)   /* Maximum number of
+						       ISCSI connections per
+						       chute */
+#define MAX_RDMA_CIDS                   (0)     /* Maximum number of
+						       RDMA connections */
+
+#elif (BE_CONFIG == 4)
+
+/* --- CID_START_ENUM --- */
+#define ISCSI_CID_START                 (0)     /* Start of connection
+						       ID range for ISCSI */
+#define DEFPDU_CID_START                (0)     /* Start of connection
+						       ID range for iSCSI
+						       default pdu queue */
+#define ETX_CID_START                   (1024)  /* Start of connection
+						       ID range for ETX */
+#define RDMA_CID_START                  (0)     /* Start of connection
+						       ID range for RDMA */
+
+/* --- MAX_CIDS_ENUM --- */
+#define MAX_DEFPDU_CIDS                 (32)    /* Maximum number of
+						       iSCSI DEF pdu cids */
+#define MAX_ETX_CIDS                    (64)    /* Maximum number of
+						       ETX connections */
+#define MAX_ISCSI_CIDS                  (512)   /* Maximum number of
+						       ISCSI connections */
+#define MAX_ISCSI_CIDS_CT               (256)   /* Maximum number of
+						       ISCSI connections per
+						       chute */
+#define MAX_RDMA_CIDS                   (0)     /* Maximum number of
+						       RDMA connections */
+
+
+#else
+#error Error: Invalid configuration (BE_CONFIG unrecognized).
+#endif
+
+
+/* Define the ethernet CIDs used for iSCSI OOO packet replay. Currently
+ * the maximum number of iSCSI chutes/ulps is 2. Each iSCSI chute
+ * requries one reserved CID number.  We have chosen the following
+ * format for these literals:
+ * a) ISCSI_OOO_CID - used for replay from iSCSI chute A (rxulp0),
+ * 		must be an even number
+ * b) ISCSI_OOO_CID1 - used for replay from iSCSI chute B (rxulp1),
+ * 		must be adjacent to
+ *    chute A's CID, only applicable on dual-chute iSCSI
+ */
+#define ISCSI_OOO_CID                       (1086)
+#define ISCSI_OOO_CID1                      (1087)
+
+
+/* Define the ethernet CIDs that have higher priority over normal
+ * ethernet transmit rings. Each etx ULP requires one reserved super
+ * CID number.  Currently the maximum number of ethernet chutes is 2.
+ * We have chosen the following format for these literals:
+ * a) ETX_SUPER_CID_ULP2 - used for etx with txulp2
+ * b) ETX_SUPER_CID_ULP1 - used for etx with txulp1
+ *
+ */
+#define ETX_SUPER_CID_ULP2                  (ETX_CID_START)
+#define ETX_SUPER_CID_ULP1                  (ETX_CID_START + 1)
+
+#endif /* __be_gen_id_ranges_h__ */
+
diff --git a/drivers/message/beclib/fw/bmap/be_common_bmap.h b/drivers/message/beclib/fw/bmap/be_common_bmap.h
new file mode 100644
index 0000000..b73a528
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/be_common_bmap.h
@@ -0,0 +1,56 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __be_common_bmap_h__
+#define __be_common_bmap_h__
+
+#ifndef SG_C_ASSERT
+#define SG_C_ASSERT(_name_, _condition_)
+#endif
+
+#if defined(__BIG_ENDIAN)
+   /* Physical Address. */
+struct PHYS_ADDR {
+	union {
+		struct {
+			u32 lo;	/* DWORD 0 */
+			u32 hi;	/* DWORD 1 */
+		} SG_PACK;	/* unnamed struct */
+		u32 dw[2];	/* dword union */
+	};			/* unnamed union */
+} SG_PACK ;
+
+SG_C_ASSERT(__sizeof__PHYS_ADDR, sizeof(struct PHYS_ADDR) == 8);
+
+#else
+   /* Physical Address. */
+struct PHYS_ADDR {
+	union {
+		struct {
+			u32 lo;	/* DWORD 0 */
+			u32 hi;	/* DWORD 1 */
+		} SG_PACK;	/* unnamed struct */
+		u32 dw[2];	/* dword union */
+	};			/* unnamed union */
+} SG_PACK ;
+
+SG_C_ASSERT(__sizeof__PHYS_ADDR, sizeof(struct PHYS_ADDR) == 8);
+#endif
+
+#endif /* __be_common_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/fwcmd_common_bmap.h b/drivers/message/beclib/fw/bmap/fwcmd_common_bmap.h
new file mode 100644
index 0000000..3cd4816
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/fwcmd_common_bmap.h
@@ -0,0 +1,691 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __fwcmd_common_bmap_h__
+#define __fwcmd_common_bmap_h__
+#include "fwcmd_types_bmap.h"
+#include "fwcmd_hdr_bmap.h"
+
+struct BE_LINK_STATUS {
+	u8 mac0_duplex;
+	u8 mac0_speed;
+	u8 mac1_duplex;
+	u8 mac1_speed;
+	u8 mgmt_mac_duplex;
+	u8 mgmt_mac_speed;
+	u8 active_port;
+	u8 rsvd0;
+	u8 mac0_fault;
+	u8 mac1_fault;
+	u16 rsvd1;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_170_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+union LINK_STATUS_QUERY_PARAMS {
+	struct BE_LINK_STATUS response;
+	struct FWCMD_COMMON_ANON_170_REQUEST request;
+} SG_PACK;
+
+/*
+ *  Queries the the link status for all ports.  The valid values below
+ *  DO NOT indicate that  a particular duplex or speed is supported by
+ *  BladeEngine. These enumerations simply  list all possible duplexes
+ *  and speeds for any port. Consult BladeEngine product  documentation
+ *  for the supported parameters.
+ */
+struct FWCMD_COMMON_NTWK_LINK_STATUS_QUERY {
+	union FWCMD_HEADER header;
+	union LINK_STATUS_QUERY_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_171_REQUEST {
+	u8 type;
+	u8 port;
+	u8 mac1;
+	u8 permanent;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_172_RESPONSE {
+	struct MAC_ADDRESS_FORMAT mac;
+} SG_PACK;
+
+union NTWK_MAC_QUERY_PARAMS {
+	struct FWCMD_COMMON_ANON_171_REQUEST request;
+	struct FWCMD_COMMON_ANON_172_RESPONSE response;
+} SG_PACK;
+
+/* Queries one MAC address.  */
+struct FWCMD_COMMON_NTWK_MAC_QUERY {
+	union FWCMD_HEADER header;
+	union NTWK_MAC_QUERY_PARAMS params;
+} SG_PACK;
+
+struct MAC_SET_PARAMS_IN {
+	u8 type;
+	u8 port;
+	u8 mac1;
+	u8 invalidate;
+	struct MAC_ADDRESS_FORMAT mac;
+} SG_PACK;
+
+struct MAC_SET_PARAMS_OUT {
+	u32 rsvd0;
+} SG_PACK;
+
+union MAC_SET_PARAMS {
+	struct MAC_SET_PARAMS_IN request;
+	struct MAC_SET_PARAMS_OUT response;
+} SG_PACK;
+
+/* Sets a MAC address.  */
+struct FWCMD_COMMON_NTWK_MAC_SET {
+	union FWCMD_HEADER header;
+	union MAC_SET_PARAMS params;
+} SG_PACK;
+
+/* MAC address list. */
+struct NTWK_MULTICAST_MAC_LIST {
+	u8 byte[6];
+} SG_PACK;
+
+struct FWCMD_COMMON_NTWK_MULTICAST_SET_REQUEST_PAYLOAD {
+	u16 num_mac;
+	u8 promiscuous;
+	u8 rsvd0;
+	struct NTWK_MULTICAST_MAC_LIST mac[32];
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_174_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_173_PARAMS {
+	struct FWCMD_COMMON_NTWK_MULTICAST_SET_REQUEST_PAYLOAD request;
+	struct FWCMD_COMMON_ANON_174_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets multicast address hash. The MPU will merge the MAC address lists
+ *  from all clients,  including the networking and storage functions.
+ *  This command may fail if the final merged  list of MAC addresses exceeds
+ *  32 entries.
+ */
+struct FWCMD_COMMON_NTWK_MULTICAST_SET {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_173_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_NTWK_VLAN_CONFIG_REQUEST_PAYLOAD {
+	u16 num_vlan;
+	u8 promiscuous;
+	u8 rsvd0;
+	u16 vlan_tag[32];
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_176_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_175_PARAMS {
+	struct FWCMD_COMMON_NTWK_VLAN_CONFIG_REQUEST_PAYLOAD request;
+	struct FWCMD_COMMON_ANON_176_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets VLAN tag filter. The MPU will merge the VLAN tag list from all
+ *  clients, including  the networking and storage functions. This command
+ *  may fail if the final vlan_tag array  (from all functions) is longer
+ *  than 32 entries.
+ */
+struct FWCMD_COMMON_NTWK_VLAN_CONFIG {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_175_PARAMS params;
+} SG_PACK;
+
+struct RING_DESTROY_REQUEST {
+	u16 ring_type;
+	u16 id;
+	u8 bypass_flush;
+	u8 rsvd0;
+	u16 rsvd1;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_190_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_189_PARAMS {
+	struct RING_DESTROY_REQUEST request;
+	struct FWCMD_COMMON_ANON_190_RESPONSE response;
+} SG_PACK;
+/*
+ *  Command for destroying any ring. The connection(s) using the ring should
+ *  be quiesced  before destroying the ring.
+ */
+struct FWCMD_COMMON_RING_DESTROY {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_189_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_192_REQUEST {
+	u16 num_pages;
+	u16 rsvd0;
+	struct CQ_CONTEXT_AMAP context;
+	struct PHYS_ADDR pages[4];
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_193_RESPONSE {
+	u16 cq_id;
+} SG_PACK ;
+
+union FWCMD_COMMON_ANON_191_PARAMS {
+	struct FWCMD_COMMON_ANON_192_REQUEST request;
+	struct FWCMD_COMMON_ANON_193_RESPONSE response;
+} SG_PACK ;
+
+/*
+ *  Command for creating a completion queue. A Completion Queue must span
+ *  at least 1 page and  at most 4 pages. Each completion queue entry
+ *  is 16 bytes regardless of CQ entry format.  Thus the ring must be
+ *  at least 256 entries deep (corresponding to 1 page) and can be at
+ *   most 1024 entries deep (corresponding to 4 pages). The number of
+ *  pages posted must  contain the CQ ring size as encoded in the context.
+ *
+ */
+struct FWCMD_COMMON_CQ_CREATE {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_191_PARAMS params;
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_198_REQUEST {
+	u16 num_pages;
+	u16 rsvd0;
+	struct EQ_CONTEXT_AMAP context;
+	struct PHYS_ADDR pages[8];
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_199_RESPONSE {
+	u16 eq_id;
+} SG_PACK ;
+
+union FWCMD_COMMON_ANON_197_PARAMS {
+	struct FWCMD_COMMON_ANON_198_REQUEST request;
+	struct FWCMD_COMMON_ANON_199_RESPONSE response;
+} SG_PACK ;
+
+/*
+ *  Command for creating a event queue. An Event Queue must span at least
+ *  1 page and at most  8 pages. The number of pages posted must contain
+ *  the EQ ring. The ring is defined by  the size of the EQ entries (encoded
+ *  in the context) and the number of EQ entries (also  encoded in the
+ *  context).
+ */
+struct FWCMD_COMMON_EQ_CREATE {
+	union  FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_197_PARAMS params;
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_201_REQUEST {
+	u16 cq_id;
+	u16 bcmc_cq_id;
+	u16 num_pages;
+	u16 rsvd0;
+	struct PHYS_ADDR pages[2];
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_202_RESPONSE {
+	u16 id;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_200_PARAMS {
+	struct FWCMD_COMMON_ANON_201_REQUEST request;
+	struct FWCMD_COMMON_ANON_202_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Command for creating Ethernet receive ring.  An ERX ring contains ETH_RX_D
+ *  entries (8  bytes each). An ERX ring must be 1024 entries deep
+ *  (corresponding to 2 pages).
+ */
+struct FWCMD_COMMON_ETH_RX_CREATE {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_200_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_204_REQUEST {
+	u16 num_pages;
+	u8 ulp_num;
+	u8 type;
+	struct ETX_CONTEXT_AMAP context;
+	struct PHYS_ADDR pages[8];
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_205_RESPONSE {
+	u16 cid;
+	u8 ulp_num;
+	u8 rsvd0;
+} SG_PACK ;
+
+union FWCMD_COMMON_ANON_203_PARAMS {
+	struct FWCMD_COMMON_ANON_204_REQUEST request;
+	struct FWCMD_COMMON_ANON_205_RESPONSE response;
+} SG_PACK ;
+
+/*
+ *  Command for creating an Ethernet transmit ring.  An ETX ring contains
+ *  ETH_WRB entries (16  bytes each). An ETX ring must be at least 256
+ *  entries deep (corresponding to 1 page)  and at most 2k entries deep
+ *  (corresponding to 8 pages).
+ */
+struct FWCMD_COMMON_ETH_TX_CREATE {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_203_PARAMS params;
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_222_REQUEST {
+	u16 num_pages;
+	u16 rsvd0;
+	struct MCC_RING_CONTEXT_AMAP context;
+	struct PHYS_ADDR pages[8];
+} SG_PACK ;
+
+struct FWCMD_COMMON_ANON_223_RESPONSE {
+	u16 id;
+} SG_PACK ;
+
+union FWCMD_COMMON_ANON_221_PARAMS {
+	struct FWCMD_COMMON_ANON_222_REQUEST request;
+	struct FWCMD_COMMON_ANON_223_RESPONSE response;
+} SG_PACK ;
+
+/*
+ *  Command for creating the MCC ring. An MCC ring must be at least 16
+ *  entries deep  (corresponding to 1 page) and at most 128 entries deep
+ *  (corresponding to 8 pages).
+ */
+struct FWCMD_COMMON_MCC_CREATE {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_221_PARAMS params;
+} SG_PACK ;
+
+struct GET_QOS_IN {
+	u32 qos_params_rsvd;
+} SG_PACK;
+
+struct GET_QOS_OUT {
+	u32 max_bits_per_second_NIC;
+	u32 max_packets_per_second_NIC;
+	u32 max_ios_per_second_iSCSI;
+	u32 max_bytes_per_second_iSCSI;
+	u16 domain_VLAN_tag;
+	u16 fabric_domain_ID;
+	u32 qos_params_oem[4];
+} SG_PACK;
+
+union GET_QOS_PARAMS {
+	struct GET_QOS_IN request;
+	struct GET_QOS_OUT response;
+} SG_PACK;
+
+/* QOS/Bandwidth settings per domain. Applicable only in VMs.  */
+struct FWCMD_COMMON_GET_QOS {
+	union FWCMD_HEADER header;
+	union GET_QOS_PARAMS params;
+} SG_PACK;
+
+struct SET_QOS_IN {
+	u32 valid_flags;
+	u32 max_bits_per_second_NIC;
+	u32 max_packets_per_second_NIC;
+	u32 max_ios_per_second_iSCSI;
+	u32 max_bytes_per_second_iSCSI;
+	u16 domain_VLAN_tag;
+	u16 fabric_domain_ID;
+	u32 qos_params_oem[4];
+} SG_PACK;
+
+struct SET_QOS_OUT {
+	u32 qos_params_rsvd;
+} SG_PACK;
+
+union SET_QOS_PARAMS {
+	struct SET_QOS_IN request;
+	struct SET_QOS_OUT response;
+} SG_PACK;
+
+/* QOS/Bandwidth settings per domain. Applicable only in VMs.  */
+struct FWCMD_COMMON_SET_QOS {
+	union FWCMD_HEADER header;
+	union SET_QOS_PARAMS params;
+} SG_PACK;
+
+struct SET_FRAME_SIZE_IN {
+	u32 max_tx_frame_size;
+	u32 max_rx_frame_size;
+} SG_PACK;
+
+struct SET_FRAME_SIZE_OUT {
+	u32 chip_max_tx_frame_size;
+	u32 chip_max_rx_frame_size;
+} SG_PACK;
+
+union SET_FRAME_SIZE_PARAMS {
+	struct SET_FRAME_SIZE_IN request;
+	struct SET_FRAME_SIZE_OUT response;
+} SG_PACK;
+
+/* Set frame size command. Only host domain may issue this command.  */
+struct FWCMD_COMMON_SET_FRAME_SIZE {
+	union FWCMD_HEADER header;
+	union SET_FRAME_SIZE_PARAMS params;
+} SG_PACK;
+
+struct FORCE_FAILOVER_IN {
+	u32 move_to_port;
+	u32 failover_config;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_231_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_230_PARAMS {
+	struct FORCE_FAILOVER_IN request;
+	struct FWCMD_COMMON_ANON_231_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Use this command to control failover in BladeEngine. It may be used
+ *  to failback to a  restored port or to forcibly move traffic from
+ *  one port to another. It may also be used  to enable or disable the
+ *  automatic failover feature. This command can only be issued by  domain
+ *  0.
+ */
+struct FWCMD_COMMON_FORCE_FAILOVER {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_230_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_240_REQUEST {
+	u64 context;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_241_RESPONSE {
+	u64 context;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_239_PARAMS {
+	struct FWCMD_COMMON_ANON_240_REQUEST request;
+	struct FWCMD_COMMON_ANON_241_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  This command can be used by clients as a no-operation request. Typical
+ *  uses for drivers  are as a heartbeat mechanism, or deferred processing
+ *  catalyst. The ARM will always  complete this command with a good completion.
+ *  The 64-bit parameter is not touched by the  ARM processor.
+ */
+struct FWCMD_COMMON_NOP {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_239_PARAMS params;
+} SG_PACK;
+
+struct NTWK_RX_FILTER_SETTINGS {
+	u8 promiscuous;
+	u8 ip_cksum;
+	u8 tcp_cksum;
+	u8 udp_cksum;
+	u8 pass_err;
+	u8 pass_ckerr;
+	u8 strip_crc;
+	u8 mcast_en;
+	u8 bcast_en;
+	u8 mcast_promiscuous_en;
+	u8 unicast_en;
+	u8 vlan_promiscuous;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_242_PARAMS {
+	struct NTWK_RX_FILTER_SETTINGS request;
+	struct NTWK_RX_FILTER_SETTINGS response;
+} SG_PACK;
+
+/*
+ *  This command is used to modify the ethernet receive filter configuration.
+ *  Only domain 0  network function drivers may issue this command. The
+ *  applied configuration is returned in  the response payload. Note:
+ *  Some receive packet filter settings are global on  BladeEngine and
+ *  can affect both the storage and network function clients that the
+ *   BladeEngine hardware and firmware serve. Additionaly, depending
+ *  on the revision of  BladeEngine, some ethernet receive filter settings
+ *  are dependent on others. If a  dependency exists between settings
+ *  for the BladeEngine revision, and the command request  settings do
+ *  not meet the dependency requirement, the invalid settings will not
+ *  be  applied despite the comand succeeding. For example: a driver may
+ *  request to enable  broadcast packets, but not enable multicast packets.
+ *  On early revisions of BladeEngine,  there may be no distinction between
+ *  broadcast and multicast filters, so broadcast could  not be enabled
+ *  without enabling multicast. In this scenario, the comand would still
+ *   succeed, but the response payload would indicate the previously
+ *  configured broadcast  and multicast setting.
+ */
+struct FWCMD_COMMON_NTWK_RX_FILTER {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_242_PARAMS params;
+} SG_PACK;
+
+
+struct FWCMD_COMMON_ANON_244_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD {
+	u8 firmware_version_string[32];
+	u8 fw_on_flash_version_string[32];
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_243_PARAMS {
+	struct FWCMD_COMMON_ANON_244_REQUEST request;
+	struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD response;
+} SG_PACK;
+
+/* This comand retrieves the firmware version.  */
+struct FWCMD_COMMON_GET_FW_VERSION {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_243_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_246_REQUEST {
+	u16 tx_flow_control;
+	u16 rx_flow_control;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_247_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_245_PARAMS {
+	struct FWCMD_COMMON_ANON_246_REQUEST request;
+	struct FWCMD_COMMON_ANON_247_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  This comand is used to program BladeEngine flow control behavior.
+ *  Only the host  networking driver is allowed to use this comand.
+ */
+struct FWCMD_COMMON_SET_FLOW_CONTROL {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_245_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_249_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_250_RESPONSE {
+	u16 tx_flow_control;
+	u16 rx_flow_control;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_248_PARAMS {
+	struct FWCMD_COMMON_ANON_249_REQUEST request;
+	struct FWCMD_COMMON_ANON_250_RESPONSE response;
+} SG_PACK;
+
+/* This comand is used to read BladeEngine flow control settings.  */
+struct FWCMD_COMMON_GET_FLOW_CONTROL {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_248_PARAMS params;
+} SG_PACK;
+
+struct EQ_DELAY_PARAMS {
+	u32 eq_id;
+	u32 delay_in_microseconds;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_257_REQUEST {
+	u32 num_eq;
+	u32 rsvd0;
+	struct EQ_DELAY_PARAMS delay[16];
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_258_RESPONSE {
+	u32 delay_resolution_in_microseconds;
+	u32 delay_max_in_microseconds;
+} SG_PACK;
+
+union MODIFY_EQ_DELAY_PARAMS {
+	struct FWCMD_COMMON_ANON_257_REQUEST request;
+	struct FWCMD_COMMON_ANON_258_RESPONSE response;
+} SG_PACK;
+
+/* This comand changes the EQ delay for a given set of EQs.  */
+struct FWCMD_COMMON_MODIFY_EQ_DELAY {
+	union FWCMD_HEADER header;
+	union MODIFY_EQ_DELAY_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_260_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+struct BE_FIRMWARE_CONFIG {
+	u16 be_config_number;
+	u16 asic_revision;
+	u32 nic_ulp_mask;
+	u32 tulp_mask;
+	u32 iscsi_ulp_mask;
+	u32 rdma_ulp_mask;
+	u32 rsvd0[4];
+	u32 eth_tx_id_start;
+	u32 eth_tx_id_count;
+	u32 eth_rx_id_start;
+	u32 eth_rx_id_count;
+	u32 tpm_wrbq_id_start;
+	u32 tpm_wrbq_id_count;
+	u32 tpm_defq_id_start;
+	u32 tpm_defq_id_count;
+	u32 iscsi_wrbq_id_start;
+	u32 iscsi_wrbq_id_count;
+	u32 iscsi_defq_id_start;
+	u32 iscsi_defq_id_count;
+	u32 rdma_qp_id_start;
+	u32 rdma_qp_id_count;
+	u32 rsvd1[8];
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_259_PARAMS {
+	struct FWCMD_COMMON_ANON_260_REQUEST request;
+	struct BE_FIRMWARE_CONFIG response;
+} SG_PACK;
+
+/*
+ *  This comand queries the current firmware configuration parameters.
+ *   The static  configuration type is defined by be_config_number. This
+ *  differentiates different  BladeEngine builds, such as iSCSI Initiator
+ *  versus iSCSI Target.  For a given static  configuration, the Upper
+ *  Layer Protocol (ULP) processors may be reconfigured to support  different
+ *  protocols. Each ULP processor supports one or more protocols. The
+ *  masks  indicate which processors are configured for each protocol.
+ *   For a given static  configuration, the number of TCP connections
+ *  supported for each protocol may vary. The  *_id_start and *_id_count
+ *  variables define a linear range of IDs that are available for  each
+ *  supported protocol. The *_id_count may be used by the driver to allocate
+ *  the  appropriate number of connection resources. The *_id_start may
+ *  be used to map the  arbitrary range of IDs to a zero-based range
+ *  of indices.
+ */
+struct FWCMD_COMMON_FIRMWARE_CONFIG {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_259_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_PORT_EQUALIZATION_PARAMS {
+	u32 emph_lev_sel_port0;
+	u32 emph_lev_sel_port1;
+	u8 xaui_vo_sel;
+	u8 xaui_state;
+	u16 rsvd0;
+	u32 xaui_eq_vector;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_262_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_261_PARAMS {
+	struct FWCMD_COMMON_ANON_262_REQUEST request;
+	struct FWCMD_COMMON_PORT_EQUALIZATION_PARAMS response;
+} SG_PACK;
+
+/*
+ *  This comand can be used to read XAUI equalization parameters. The
+ *  ARM firmware applies  default equalization parameters during initialization.
+ *  These parameters may be  customer-specific when derived from the
+ *  SEEPROM. See SEEPROM_DATA for equalization  specific fields.
+ */
+struct FWCMD_COMMON_GET_PORT_EQUALIZATION {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_261_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_COMMON_ANON_264_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_COMMON_ANON_263_PARAMS {
+	struct FWCMD_COMMON_PORT_EQUALIZATION_PARAMS request;
+	struct FWCMD_COMMON_ANON_264_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  This comand can be used to set XAUI equalization parameters. The ARM
+ *  firmware applies  default equalization parameters during initialization.
+ *  These parameters may be  customer-specific when derived from the
+ *  SEEPROM. See SEEPROM_DATA for equalization  specific fields.
+ */
+struct FWCMD_COMMON_SET_PORT_EQUALIZATION {
+	union FWCMD_HEADER header;
+	union FWCMD_COMMON_ANON_263_PARAMS params;
+} SG_PACK;
+
+#endif /* __fwcmd_common_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/fwcmd_eth_bmap.h b/drivers/message/beclib/fw/bmap/fwcmd_eth_bmap.h
new file mode 100644
index 0000000..4551560
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/fwcmd_eth_bmap.h
@@ -0,0 +1,309 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __fwcmd_eth_bmap_h__
+#define __fwcmd_eth_bmap_h__
+#include "fwcmd_hdr_bmap.h"
+#include "fwcmd_types_bmap.h"
+
+struct MIB_ETH_STATISTICS_PARAMS_IN {
+	u32 rsvd0;
+} SG_PACK;
+
+struct BE_RXF_STATS {
+	u32 p0recvdtotalbytesLSD;	/* DWORD 0 */
+	u32 p0recvdtotalbytesMSD;	/* DWORD 1 */
+	u32 p0recvdtotalframes;	/* DWORD 2 */
+	u32 p0recvdunicastframes;	/* DWORD 3 */
+	u32 p0recvdmulticastframes;	/* DWORD 4 */
+	u32 p0recvdbroadcastframes;	/* DWORD 5 */
+	u32 p0crcerrors;	/* DWORD 6 */
+	u32 p0alignmentsymerrs;	/* DWORD 7 */
+	u32 p0pauseframesrecvd;	/* DWORD 8 */
+	u32 p0controlframesrecvd;	/* DWORD 9 */
+	u32 p0inrangelenerrors;	/* DWORD 10 */
+	u32 p0outrangeerrors;	/* DWORD 11 */
+	u32 p0frametoolongerrors;	/* DWORD 12 */
+	u32 p0droppedaddressmatch;	/* DWORD 13 */
+	u32 p0droppedvlanmismatch;	/* DWORD 14 */
+	u32 p0ipdroppedtoosmall;	/* DWORD 15 */
+	u32 p0ipdroppedtooshort;	/* DWORD 16 */
+	u32 p0ipdroppedhdrtoosmall;	/* DWORD 17 */
+	u32 p0tcpdroppedlen;	/* DWORD 18 */
+	u32 p0droppedrunt;	/* DWORD 19 */
+	u32 p0recvd64;		/* DWORD 20 */
+	u32 p0recvd65_127;	/* DWORD 21 */
+	u32 p0recvd128_256;	/* DWORD 22 */
+	u32 p0recvd256_511;	/* DWORD 23 */
+	u32 p0recvd512_1023;	/* DWORD 24 */
+	u32 p0recvd1518_1522;	/* DWORD 25 */
+	u32 p0recvd1522_2047;	/* DWORD 26 */
+	u32 p0recvd2048_4095;	/* DWORD 27 */
+	u32 p0recvd4096_8191;	/* DWORD 28 */
+	u32 p0recvd8192_9216;	/* DWORD 29 */
+	u32 p0rcvdipcksmerrs;	/* DWORD 30 */
+	u32 p0recvdtcpcksmerrs;	/* DWORD 31 */
+	u32 p0recvdudpcksmerrs;	/* DWORD 32 */
+	u32 p0recvdnonrsspackets;	/* DWORD 33 */
+	u32 p0recvdippackets;	/* DWORD 34 */
+	u32 p0recvdchute1packets;	/* DWORD 35 */
+	u32 p0recvdchute2packets;	/* DWORD 36 */
+	u32 p0recvdchute3packets;	/* DWORD 37 */
+	u32 p0recvdipsecpackets;	/* DWORD 38 */
+	u32 p0recvdmanagementpackets;	/* DWORD 39 */
+	u32 p0xmitbyteslsd;	/* DWORD 40 */
+	u32 p0xmitbytesmsd;	/* DWORD 41 */
+	u32 p0xmitunicastframes;	/* DWORD 42 */
+	u32 p0xmitmulticastframes;	/* DWORD 43 */
+	u32 p0xmitbroadcastframes;	/* DWORD 44 */
+	u32 p0xmitpauseframes;	/* DWORD 45 */
+	u32 p0xmitcontrolframes;	/* DWORD 46 */
+	u32 p0xmit64;		/* DWORD 47 */
+	u32 p0xmit65_127;	/* DWORD 48 */
+	u32 p0xmit128_256;	/* DWORD 49 */
+	u32 p0xmit256_511;	/* DWORD 50 */
+	u32 p0xmit512_1023;	/* DWORD 51 */
+	u32 p0xmit1518_1522;	/* DWORD 52 */
+	u32 p0xmit1522_2047;	/* DWORD 53 */
+	u32 p0xmit2048_4095;	/* DWORD 54 */
+	u32 p0xmit4096_8191;	/* DWORD 55 */
+	u32 p0xmit8192_9216;	/* DWORD 56 */
+	u32 p0rxfifooverflowdropped;	/* DWORD 57 */
+	u32 p0ipseclookupfaileddropped;	/* DWORD 58 */
+	u32 p1recvdtotalbytesLSD;	/* DWORD 59 */
+	u32 p1recvdtotalbytesMSD;	/* DWORD 60 */
+	u32 p1recvdtotalframes;	/* DWORD 61 */
+	u32 p1recvdunicastframes;	/* DWORD 62 */
+	u32 p1recvdmulticastframes;	/* DWORD 63 */
+	u32 p1recvdbroadcastframes;	/* DWORD 64 */
+	u32 p1crcerrors;	/* DWORD 65 */
+	u32 p1alignmentsymerrs;	/* DWORD 66 */
+	u32 p1pauseframesrecvd;	/* DWORD 67 */
+	u32 p1controlframesrecvd;	/* DWORD 68 */
+	u32 p1inrangelenerrors;	/* DWORD 69 */
+	u32 p1outrangeerrors;	/* DWORD 70 */
+	u32 p1frametoolongerrors;	/* DWORD 71 */
+	u32 p1droppedaddressmatch;	/* DWORD 72 */
+	u32 p1droppedvlanmismatch;	/* DWORD 73 */
+	u32 p1ipdroppedtoosmall;	/* DWORD 74 */
+	u32 p1ipdroppedtooshort;	/* DWORD 75 */
+	u32 p1ipdroppedhdrtoosmall;	/* DWORD 76 */
+	u32 p1tcpdroppedlen;	/* DWORD 77 */
+	u32 p1droppedrunt;	/* DWORD 78 */
+	u32 p1recvd64;		/* DWORD 79 */
+	u32 p1recvd65_127;	/* DWORD 80 */
+	u32 p1recvd128_256;	/* DWORD 81 */
+	u32 p1recvd256_511;	/* DWORD 82 */
+	u32 p1recvd512_1023;	/* DWORD 83 */
+	u32 p1recvd1518_1522;	/* DWORD 84 */
+	u32 p1recvd1522_2047;	/* DWORD 85 */
+	u32 p1recvd2048_4095;	/* DWORD 86 */
+	u32 p1recvd4096_8191;	/* DWORD 87 */
+	u32 p1recvd8192_9216;	/* DWORD 88 */
+	u32 p1rcvdipcksmerrs;	/* DWORD 89 */
+	u32 p1recvdtcpcksmerrs;	/* DWORD 90 */
+	u32 p1recvdudpcksmerrs;	/* DWORD 91 */
+	u32 p1recvdnonrsspackets;	/* DWORD 92 */
+	u32 p1recvdippackets;	/* DWORD 93 */
+	u32 p1recvdchute1packets;	/* DWORD 94 */
+	u32 p1recvdchute2packets;	/* DWORD 95 */
+	u32 p1recvdchute3packets;	/* DWORD 96 */
+	u32 p1recvdipsecpackets;	/* DWORD 97 */
+	u32 p1recvdmanagementpackets;	/* DWORD 98 */
+	u32 p1xmitbyteslsd;	/* DWORD 99 */
+	u32 p1xmitbytesmsd;	/* DWORD 100 */
+	u32 p1xmitunicastframes;	/* DWORD 101 */
+	u32 p1xmitmulticastframes;	/* DWORD 102 */
+	u32 p1xmitbroadcastframes;	/* DWORD 103 */
+	u32 p1xmitpauseframes;	/* DWORD 104 */
+	u32 p1xmitcontrolframes;	/* DWORD 105 */
+	u32 p1xmit64;		/* DWORD 106 */
+	u32 p1xmit65_127;	/* DWORD 107 */
+	u32 p1xmit128_256;	/* DWORD 108 */
+	u32 p1xmit256_511;	/* DWORD 109 */
+	u32 p1xmit512_1023;	/* DWORD 110 */
+	u32 p1xmit1518_1522;	/* DWORD 111 */
+	u32 p1xmit1522_2047;	/* DWORD 112 */
+	u32 p1xmit2048_4095;	/* DWORD 113 */
+	u32 p1xmit4096_8191;	/* DWORD 114 */
+	u32 p1xmit8192_9216;	/* DWORD 115 */
+	u32 p1rxfifooverflowdropped;	/* DWORD 116 */
+	u32 p1ipseclookupfaileddropped;	/* DWORD 117 */
+	u32 pxdroppednopbuf;	/* DWORD 118 */
+	u32 pxdroppednotxpb;	/* DWORD 119 */
+	u32 pxdroppednoipsecbuf;	/* DWORD 120 */
+	u32 pxdroppednoerxdescr;	/* DWORD 121 */
+	u32 pxdroppednotpredescr;	/* DWORD 122 */
+	u32 pxrecvdmanagementportpackets;	/* DWORD 123 */
+	u32 pxrecvdmanagementportbytes;	/* DWORD 124 */
+	u32 pxrecvdmanagementportpauseframes;	/* DWORD 125 */
+	u32 pxrecvdmanagementporterrors;	/* DWORD 126 */
+	u32 pxxmitmanagementportpackets;	/* DWORD 127 */
+	u32 pxxmitmanagementportbytes;	/* DWORD 128 */
+	u32 pxxmitmanagementportpause;	/* DWORD 129 */
+	u32 pxxmitmanagementportrxfifooverflow;	/* DWORD 130 */
+	u32 pxrecvdipsecipcksmerrs;	/* DWORD 131 */
+	u32 pxrecvdtcpsecipcksmerrs;	/* DWORD 132 */
+	u32 pxrecvdudpsecipcksmerrs;	/* DWORD 133 */
+	u32 pxipsecrunt;	/* DWORD 134 */
+	u32 pxipsecaddressmismatchdropped;	/* DWORD 135 */
+	u32 pxipsecrxfifooverflowdropped;	/* DWORD 136 */
+	u32 pxipsecframestoolong;	/* DWORD 137 */
+	u32 pxipsectotalipframes;	/* DWORD 138 */
+	u32 pxipseciptoosmall;	/* DWORD 139 */
+	u32 pxipseciptooshort;	/* DWORD 140 */
+	u32 pxipseciphdrtoosmall;	/* DWORD 141 */
+	u32 pxipsectcphdrbad;	/* DWORD 142 */
+	u32 pxrecvdipsecchute1;	/* DWORD 143 */
+	u32 pxrecvdipsecchute2;	/* DWORD 144 */
+	u32 pxrecvdipsecchute3;	/* DWORD 145 */
+	u32 pxdropped7frags;	/* DWORD 146 */
+	u32 pxdroppedfrags;	/* DWORD 147 */
+	u32 pxdroppedinvalidfragring;	/* DWORD 148 */
+	u32 pxnumforwardedpackets;	/* DWORD 149 */
+} SG_PACK;
+
+union MIB_ETH_STATISTICS_PARAMS {
+	struct MIB_ETH_STATISTICS_PARAMS_IN request;
+	struct BE_RXF_STATS response;
+} SG_PACK;
+
+/*
+ *  Query ethernet statistics. All domains may issue this command. The
+ *  host domain drivers  may optionally reset internal statistic counters
+ *  with a query.
+ */
+struct FWCMD_ETH_GET_STATISTICS {
+	union FWCMD_HEADER header;
+	union MIB_ETH_STATISTICS_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_ETH_ACPI_CONFIG_PARAMS {
+	u8 index;
+	u8 port0;
+	u8 port1;
+	u8 magic_packet;
+	u8 byte_pattern[128];
+	u32 bit_mask[4];
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_173_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_ETH_ANON_172_PARAMS {
+	struct FWCMD_ETH_ACPI_CONFIG_PARAMS request;
+	struct FWCMD_ETH_ANON_173_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets the magic packet or interesting packet byte pattern and mask
+ *  * for wake-on-lan.  Only host drivers are allowed to modify magic
+ *  packet * settings. Only the host  networking driver is allowed to
+ *  modify the * interesting packet byte pattern and mask  settings.
+ *
+ */
+struct FWCMD_ETH_ACPI_CONFIG {
+	union FWCMD_HEADER header;
+	union FWCMD_ETH_ANON_172_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_175_REQUEST {
+	u8 port0_promiscuous;
+	u8 port1_promiscuous;
+	u16 rsvd0;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_176_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union FWCMD_ETH_ANON_174_PARAMS {
+	struct FWCMD_ETH_ANON_175_REQUEST request;
+	struct FWCMD_ETH_ANON_176_RESPONSE response;
+} SG_PACK;
+
+/* Enables/Disables promiscuous ethernet receive mode.  */
+struct FWCMD_ETH_PROMISCUOUS {
+	union FWCMD_HEADER header;
+	union FWCMD_ETH_ANON_174_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_178_REQUEST {
+	u32 new_fragsize_log2;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_179_RESPONSE {
+	u32 actual_fragsize_log2;
+} SG_PACK;
+
+union FWCMD_ETH_ANON_177_PARAMS {
+	struct FWCMD_ETH_ANON_178_REQUEST request;
+	struct FWCMD_ETH_ANON_179_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets the Ethernet RX fragment size. Only host (domain 0) networking
+ *  drivers may issue  this command.  This call will fail for non-host
+ *  protection domains. In this situation the  MCC CQ status will indicate
+ *  a failure due to insufficient priviledges. The response  should be
+ *  ignored, and the driver should use the FWCMD_ETH_GET_FRAG_SIZE to
+ *  query the  existing ethernet receive fragment size. It must use this
+ *  fragment size for all  fragments in the ethernet receive ring.  If
+ *  the command succeeds, the driver must use the  frag size indicated
+ *  in the command response since the requested frag size may not be  applied
+ *  until the next reboot. When the requested fragsize matches the response
+ *   fragsize, this indicates the request was applied immediately.
+ */
+struct FWCMD_ETH_SET_RX_FRAG_SIZE {
+	union FWCMD_HEADER header;
+	union FWCMD_ETH_ANON_177_PARAMS params;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_181_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+struct FWCMD_ETH_ANON_182_RESPONSE {
+	u32 actual_fragsize_log2;
+} SG_PACK;
+
+union FWCMD_ETH_ANON_180_PARAMS {
+	struct FWCMD_ETH_ANON_181_REQUEST request;
+	struct FWCMD_ETH_ANON_182_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Queries the Ethernet RX fragment size. All domains may issue this
+ *  command.  The driver  should call this command to determine the minimum
+ *  required fragment size for the ethernet  RX ring buffers. Drivers
+ *  may choose to use a larger size for each fragment buffer, but  BladeEngine
+ *  will use up to the configured minimum required fragsize in each ethernet
+ *   receive fragment buffer. For example, if the ethernet receive fragment
+ *  size is  configured to 4kB, and a driver uses 8kB fragments, a 6kB
+ *  ethernet packet received by  BladeEngine will be split accross two
+ *  of the driver's receive framgents (4kB in one  fragment buffer, and
+ *  2kB in the subsequent fragment buffer).
+ */
+struct FWCMD_ETH_GET_RX_FRAG_SIZE {
+	union FWCMD_HEADER header;
+	union FWCMD_ETH_ANON_180_PARAMS params;
+} SG_PACK;
+
+#endif /* __fwcmd_eth_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/fwcmd_hdr_bmap.h b/drivers/message/beclib/fw/bmap/fwcmd_hdr_bmap.h
new file mode 100644
index 0000000..4c664a0
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/fwcmd_hdr_bmap.h
@@ -0,0 +1,54 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __fwcmd_hdr_bmap_h__
+#define __fwcmd_hdr_bmap_h__
+
+struct FWCMD_REQUEST_HEADER {
+	u8 opcode;
+	u8 subsystem;
+	u8 port_number;
+	u8 domain;
+	u32 timeout;
+	u32 request_length;
+	u32 rsvd0;
+} SG_PACK;
+
+struct FWCMD_RESPONSE_HEADER {
+	u8 opcode;
+	u8 subsystem;
+	u8 rsvd0;
+	u8 domain;
+	u8 status;
+	u8 additional_status;
+	u16 rsvd1;
+	u32 response_length;
+	u32 actual_response_length;
+} SG_PACK;
+
+/*
+ *  The firmware/driver overwrites the input FWCMD_REQUEST_HEADER with
+ *  the output  FWCMD_RESPONSE_HEADER.
+ */
+union FWCMD_HEADER {
+	struct FWCMD_REQUEST_HEADER request;
+	struct FWCMD_RESPONSE_HEADER response;
+} SG_PACK;
+
+#endif /* __fwcmd_hdr_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/fwcmd_top_bmap.h b/drivers/message/beclib/fw/bmap/fwcmd_top_bmap.h
new file mode 100644
index 0000000..b01a49a
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/fwcmd_top_bmap.h
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __fwcmd_top_bmap_h__
+#define __fwcmd_top_bmap_h__
+#include "fwcmd_types_bmap.h"
+#include "fwcmd_common_bmap.h"
+#include "fwcmd_eth_bmap.h"
+
+#endif /* __fwcmd_top_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/fwcmd_types_bmap.h b/drivers/message/beclib/fw/bmap/fwcmd_types_bmap.h
new file mode 100644
index 0000000..bc97d52
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/fwcmd_types_bmap.h
@@ -0,0 +1,29 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __fwcmd_types_bmap_h__
+#define __fwcmd_types_bmap_h__
+
+/* MAC address format  */
+struct MAC_ADDRESS_FORMAT {
+	u16 SizeOfStructure;
+	u8 MACAddress[6];
+} SG_PACK;
+
+#endif /* __fwcmd_types_bmap_h__ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

