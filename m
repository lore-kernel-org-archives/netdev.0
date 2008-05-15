From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 14/15] BE NIC driver - f/w header files
Date: Thu, 15 May 2008 02:53:41 -0700
Message-ID: <20080515095341.44b87fb2@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.245.99]:16826 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbYEOJtC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:49:02 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Thu, 15 May 2008 02:53:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/fw/be_gen_id_ranges.h      |  231 +++++++++++++
 drivers/message/beclib/fw/bmap/host_struct_bmap.h |   38 +++
 drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h   |  359 +++++++++++++++++++++
 drivers/message/beclib/fw/bmap/ioctl_top_bmap.h   |   40 +++
 4 files changed, 668 insertions(+), 0 deletions(-)
 create mode 100755 drivers/message/beclib/fw/be_gen_id_ranges.h
 create mode 100644 drivers/message/beclib/fw/bmap/host_struct_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h
 create mode 100644 drivers/message/beclib/fw/bmap/ioctl_top_bmap.h

diff --git a/drivers/message/beclib/fw/be_gen_id_ranges.h b/drivers/message/beclib/fw/be_gen_id_ranges.h
new file mode 100755
index 0000000..800bc4f
--- /dev/null
+++ b/drivers/message/beclib/fw/be_gen_id_ranges.h
@@ -0,0 +1,231 @@
+/*
+ * Copyright (C) 2005 - 2007 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*!
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
diff --git a/drivers/message/beclib/fw/bmap/host_struct_bmap.h b/drivers/message/beclib/fw/bmap/host_struct_bmap.h
new file mode 100644
index 0000000..717e507
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/host_struct_bmap.h
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
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
+#ifndef __host_struct_bmap_h__
+#define __host_struct_bmap_h__
+#include "be_common_bmap.h"
+
+#endif /* __host_struct_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h b/drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h
new file mode 100644
index 0000000..c27529e
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/ioctl_eth_bmap.h
@@ -0,0 +1,359 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
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
+#ifndef __ioctl_eth_bmap_h__
+#define __ioctl_eth_bmap_h__
+#include "ioctl_hdr_bmap.h"
+#include "ioctl_types_bmap.h"
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
+ *  Query ethernet statistics. All domains may issue this IOCTL. The
+ *  host domain drivers  may optionally reset internal statistic counters
+ *  with a query.
+ */
+struct IOCTL_ETH_GET_STATISTICS {
+	union IOCTL_HEADER header;
+	union MIB_ETH_STATISTICS_PARAMS params;
+} SG_PACK;
+
+struct BE_RSS_CONFIG {
+	u16 enable_rss;
+	u16 cpu_table_size_log2;
+	u16 cqid0;
+	u16 cqid1;
+	u16 cqid2;
+	u16 cqid3;
+	u32 hash[4];
+	u8 cpu_table[128];
+	u16 cq_flush_mask;
+	u16 rsvd0;
+	u32 flush_value;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_171_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union IOCTL_ETH_ANON_170_PARAMS {
+	struct BE_RSS_CONFIG request;
+	struct IOCTL_ETH_ANON_171_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Configures or disables receive side scaling (RSS), which distributes
+ *  ethernet receive  completions among (up to 4) completion queues.
+ *  This is in addition to the default  ethernet receive completion queue.
+ *  Presumably, the host driver processes each  completion queue with
+ *  a DPC running on a different processor. This IOCTL can only be  issued
+ *  by domain 0 network drivers.
+ */
+struct IOCTL_ETH_RSS_CONFIG {
+	union IOCTL_HEADER header;
+	union IOCTL_ETH_ANON_170_PARAMS params;
+} SG_PACK;
+
+struct IOCTL_ETH_ACPI_CONFIG_PARAMS {
+	u8 index;
+	u8 port0;
+	u8 port1;
+	u8 magic_packet;
+	u8 byte_pattern[128];
+	u32 bit_mask[4];
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_173_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union IOCTL_ETH_ANON_172_PARAMS {
+	struct IOCTL_ETH_ACPI_CONFIG_PARAMS request;
+	struct IOCTL_ETH_ANON_173_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets the magic packet or interesting packet byte pattern and mask
+ *  * for wake-on-lan.  Only host drivers are allowed to modify magic
+ *  packet * settings. Only the host  networking driver is allowed to
+ *  modify the * interesting packet byte pattern and mask  settings.
+ *
+ */
+struct IOCTL_ETH_ACPI_CONFIG {
+	union IOCTL_HEADER header;
+	union IOCTL_ETH_ANON_172_PARAMS params;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_175_REQUEST {
+	u8 port0_promiscuous;
+	u8 port1_promiscuous;
+	u16 rsvd0;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_176_RESPONSE {
+	u32 rsvd0;
+} SG_PACK;
+
+union IOCTL_ETH_ANON_174_PARAMS {
+	struct IOCTL_ETH_ANON_175_REQUEST request;
+	struct IOCTL_ETH_ANON_176_RESPONSE response;
+} SG_PACK;
+
+/* Enables/Disables promiscuous ethernet receive mode.  */
+struct IOCTL_ETH_PROMISCUOUS {
+	union IOCTL_HEADER header;
+	union IOCTL_ETH_ANON_174_PARAMS params;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_178_REQUEST {
+	u32 new_fragsize_log2;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_179_RESPONSE {
+	u32 actual_fragsize_log2;
+} SG_PACK;
+
+union IOCTL_ETH_ANON_177_PARAMS {
+	struct IOCTL_ETH_ANON_178_REQUEST request;
+	struct IOCTL_ETH_ANON_179_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Sets the Ethernet RX fragment size. Only host (domain 0) networking
+ *  drivers may issue  this IOCTL.  This call will fail for non-host
+ *  protection domains. In this situation the  MCC CQ status will indicate
+ *  a failure due to insufficient priviledges. The response  should be
+ *  ignored, and the driver should use the IOCTL_ETH_GET_FRAG_SIZE to
+ *  query the  existing ethernet receive fragment size. It must use this
+ *  fragment size for all  fragments in the ethernet receive ring.  If
+ *  the IOCTL succeeds, the driver must use the  frag size indicated
+ *  in the IOCTL response since the requested frag size may not be  applied
+ *  until the next reboot. When the requested fragsize matches the response
+ *   fragsize, this indicates the request was applied immediately.
+ */
+struct IOCTL_ETH_SET_RX_FRAG_SIZE {
+	union IOCTL_HEADER header;
+	union IOCTL_ETH_ANON_177_PARAMS params;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_181_REQUEST {
+	u32 rsvd0;
+} SG_PACK;
+
+struct IOCTL_ETH_ANON_182_RESPONSE {
+	u32 actual_fragsize_log2;
+} SG_PACK;
+
+union IOCTL_ETH_ANON_180_PARAMS {
+	struct IOCTL_ETH_ANON_181_REQUEST request;
+	struct IOCTL_ETH_ANON_182_RESPONSE response;
+} SG_PACK;
+
+/*
+ *  Queries the Ethernet RX fragment size. All domains may issue this
+ *  IOCTL.  The driver  should call this IOCTL to determine the minimum
+ *  required fragment size for the ethernet  RX ring buffers. Drivers
+ *  may choose to use a larger size for each fragment buffer, but  BladeEngine
+ *  will use up to the configured minimum required fragsize in each ethernet
+ *   receive fragment buffer. For example, if the ethernet receive fragment
+ *  size is  configured to 4kB, and a driver uses 8kB fragments, a 6kB
+ *  ethernet packet received by  BladeEngine will be split accross two
+ *  of the driver's receive framgents (4kB in one  fragment buffer, and
+ *  2kB in the subsequent fragment buffer).
+ */
+struct IOCTL_ETH_GET_RX_FRAG_SIZE {
+	union IOCTL_HEADER header;
+	union IOCTL_ETH_ANON_180_PARAMS params;
+} SG_PACK;
+
+#endif /* __ioctl_eth_bmap_h__ */
diff --git a/drivers/message/beclib/fw/bmap/ioctl_top_bmap.h b/drivers/message/beclib/fw/bmap/ioctl_top_bmap.h
new file mode 100644
index 0000000..bdb247c
--- /dev/null
+++ b/drivers/message/beclib/fw/bmap/ioctl_top_bmap.h
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
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
+#ifndef __ioctl_top_bmap_h__
+#define __ioctl_top_bmap_h__
+#include "ioctl_types_bmap.h"
+#include "ioctl_common_bmap.h"
+#include "ioctl_eth_bmap.h"
+
+#endif /* __ioctl_top_bmap_h__ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

