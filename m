From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 07/12] ixgbevf: Macros, data structures,
	useful defines and registers
Date: Tue, 08 Dec 2009 14:15:14 -0800
Message-ID: <20091208221513.28373.64700.stgit@localhost.localdomain>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:32771 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966723AbZLHWPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:15:25 -0500
In-Reply-To: <20091208221258.28373.16663.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

These two headers define the commonly used macros, data structures,
register bits and register offsets used by the ixgbevf driver on the
82599 virtual function device

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/defines.h |  301 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbevf/regs.h    |   85 ++++++++++++
 2 files changed, 386 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ixgbevf/defines.h
 create mode 100644 drivers/net/ixgbevf/regs.h

diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
new file mode 100644
index 0000000..b111771
--- /dev/null
+++ b/drivers/net/ixgbevf/defines.h
@@ -0,0 +1,301 @@
+/*******************************************************************************
+
+  Intel 82599 Virtual Function driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBEVF_DEFINES_H_
+#define _IXGBEVF_DEFINES_H_
+
+/* Device IDs */
+#define IXGBE_DEV_ID_82599_VF           0x10ED
+
+#define IXGBE_VF_IRQ_CLEAR_MASK         7
+#define IXGBE_VF_MAX_TX_QUEUES          1
+#define IXGBE_VF_MAX_RX_QUEUES          1
+#define IXGBE_ETH_LENGTH_OF_ADDRESS     6
+
+/* Link speed */
+typedef u32 ixgbe_link_speed;
+#define IXGBE_LINK_SPEED_1GB_FULL       0x0020
+#define IXGBE_LINK_SPEED_10GB_FULL      0x0080
+
+#define IXGBE_CTRL_RST          0x04000000 /* Reset (SW) */
+#define IXGBE_RXDCTL_ENABLE     0x02000000 /* Enable specific Rx Queue */
+#define IXGBE_TXDCTL_ENABLE     0x02000000 /* Enable specific Tx Queue */
+#define IXGBE_LINKS_UP          0x40000000
+#define IXGBE_LINKS_SPEED       0x20000000
+
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
+#define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE  8
+#define IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE  8
+#define IXGBE_REQ_TX_BUFFER_GRANULARITY   1024
+
+/* Interrupt Vector Allocation Registers */
+#define IXGBE_IVAR_ALLOC_VAL    0x80 /* Interrupt Allocation valid */
+
+#define IXGBE_VF_INIT_TIMEOUT   200 /* Number of retries to clear RSTI */
+
+/* Receive Config masks */
+#define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
+#define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
+#define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
+#define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
+
+/* DCA Control */
+#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
+
+/* Check whether address is multicast.  This is little-endian specific check.*/
+#define IXGBE_IS_MULTICAST(Address) \
+	(bool)(((u8 *)(Address))[0] & ((u8)0x01))
+
+/* Check whether an address is broadcast. */
+#define IXGBE_IS_BROADCAST(Address)              \
+	((((u8 *)(Address))[0] == ((u8)0xFF)) && \
+	 (((u8 *)(Address))[1] == ((u8)0xFF)))
+
+/* PSRTYPE bit definitions */
+#define IXGBE_PSRTYPE_TCPHDR    0x00000010
+#define IXGBE_PSRTYPE_UDPHDR    0x00000020
+#define IXGBE_PSRTYPE_IPV4HDR   0x00000100
+#define IXGBE_PSRTYPE_IPV6HDR   0x00000200
+#define IXGBE_PSRTYPE_L2HDR     0x00001000
+
+/* SRRCTL bit definitions */
+#define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */
+#define IXGBE_SRRCTL_RDMTS_SHIFT        22
+#define IXGBE_SRRCTL_RDMTS_MASK         0x01C00000
+#define IXGBE_SRRCTL_DROP_EN            0x10000000
+#define IXGBE_SRRCTL_BSIZEPKT_MASK      0x0000007F
+#define IXGBE_SRRCTL_BSIZEHDR_MASK      0x00003F00
+#define IXGBE_SRRCTL_DESCTYPE_LEGACY    0x00000000
+#define IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF 0x02000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT  0x04000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS 0x0A000000
+#define IXGBE_SRRCTL_DESCTYPE_MASK      0x0E000000
+
+/* Receive Descriptor bit definitions */
+#define IXGBE_RXD_STAT_DD         0x01    /* Descriptor Done */
+#define IXGBE_RXD_STAT_EOP        0x02    /* End of Packet */
+#define IXGBE_RXD_STAT_FLM        0x04    /* FDir Match */
+#define IXGBE_RXD_STAT_VP         0x08    /* IEEE VLAN Packet */
+#define IXGBE_RXDADV_NEXTP_MASK   0x000FFFF0 /* Next Descriptor Index */
+#define IXGBE_RXDADV_NEXTP_SHIFT  0x00000004
+#define IXGBE_RXD_STAT_UDPCS      0x10    /* UDP xsum calculated */
+#define IXGBE_RXD_STAT_L4CS       0x20    /* L4 xsum calculated */
+#define IXGBE_RXD_STAT_IPCS       0x40    /* IP xsum calculated */
+#define IXGBE_RXD_STAT_PIF        0x80    /* passed in-exact filter */
+#define IXGBE_RXD_STAT_CRCV       0x100   /* Speculative CRC Valid */
+#define IXGBE_RXD_STAT_VEXT       0x200   /* 1st VLAN found */
+#define IXGBE_RXD_STAT_UDPV       0x400   /* Valid UDP checksum */
+#define IXGBE_RXD_STAT_DYNINT     0x800   /* Pkt caused INT via DYNINT */
+#define IXGBE_RXD_STAT_TS         0x10000 /* Time Stamp */
+#define IXGBE_RXD_STAT_SECP       0x20000 /* Security Processing */
+#define IXGBE_RXD_STAT_LB         0x40000 /* Loopback Status */
+#define IXGBE_RXD_STAT_ACK        0x8000  /* ACK Packet indication */
+#define IXGBE_RXD_ERR_CE          0x01    /* CRC Error */
+#define IXGBE_RXD_ERR_LE          0x02    /* Length Error */
+#define IXGBE_RXD_ERR_PE          0x08    /* Packet Error */
+#define IXGBE_RXD_ERR_OSE         0x10    /* Oversize Error */
+#define IXGBE_RXD_ERR_USE         0x20    /* Undersize Error */
+#define IXGBE_RXD_ERR_TCPE        0x40    /* TCP/UDP Checksum Error */
+#define IXGBE_RXD_ERR_IPE         0x80    /* IP Checksum Error */
+#define IXGBE_RXDADV_ERR_MASK     0xFFF00000 /* RDESC.ERRORS mask */
+#define IXGBE_RXDADV_ERR_SHIFT    20         /* RDESC.ERRORS shift */
+#define IXGBE_RXDADV_ERR_HBO      0x00800000 /*Header Buffer Overflow */
+#define IXGBE_RXDADV_ERR_CE       0x01000000 /* CRC Error */
+#define IXGBE_RXDADV_ERR_LE       0x02000000 /* Length Error */
+#define IXGBE_RXDADV_ERR_PE       0x08000000 /* Packet Error */
+#define IXGBE_RXDADV_ERR_OSE      0x10000000 /* Oversize Error */
+#define IXGBE_RXDADV_ERR_USE      0x20000000 /* Undersize Error */
+#define IXGBE_RXDADV_ERR_TCPE     0x40000000 /* TCP/UDP Checksum Error */
+#define IXGBE_RXDADV_ERR_IPE      0x80000000 /* IP Checksum Error */
+#define IXGBE_RXD_VLAN_ID_MASK    0x0FFF  /* VLAN ID is in lower 12 bits */
+#define IXGBE_RXD_PRI_MASK        0xE000  /* Priority is in upper 3 bits */
+#define IXGBE_RXD_PRI_SHIFT       13
+#define IXGBE_RXD_CFI_MASK        0x1000  /* CFI is bit 12 */
+#define IXGBE_RXD_CFI_SHIFT       12
+
+#define IXGBE_RXDADV_STAT_DD            IXGBE_RXD_STAT_DD  /* Done */
+#define IXGBE_RXDADV_STAT_EOP           IXGBE_RXD_STAT_EOP /* End of Packet */
+#define IXGBE_RXDADV_STAT_FLM           IXGBE_RXD_STAT_FLM /* FDir Match */
+#define IXGBE_RXDADV_STAT_VP            IXGBE_RXD_STAT_VP  /* IEEE VLAN Pkt */
+#define IXGBE_RXDADV_STAT_MASK          0x000FFFFF /* Stat/NEXTP: bit 0-19 */
+#define IXGBE_RXDADV_STAT_FCEOFS        0x00000040 /* FCoE EOF/SOF Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT        0x00000030 /* FCoE Pkt Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT_NOMTCH 0x00000000 /* 00: No Ctxt Match */
+#define IXGBE_RXDADV_STAT_FCSTAT_NODDP  0x00000010 /* 01: Ctxt w/o DDP */
+#define IXGBE_RXDADV_STAT_FCSTAT_FCPRSP 0x00000020 /* 10: Recv. FCP_RSP */
+#define IXGBE_RXDADV_STAT_FCSTAT_DDP    0x00000030 /* 11: Ctxt w/ DDP */
+
+#define IXGBE_RXDADV_RSSTYPE_MASK       0x0000000F
+#define IXGBE_RXDADV_PKTTYPE_MASK       0x0000FFF0
+#define IXGBE_RXDADV_PKTTYPE_MASK_EX    0x0001FFF0
+#define IXGBE_RXDADV_HDRBUFLEN_MASK     0x00007FE0
+#define IXGBE_RXDADV_RSCCNT_MASK        0x001E0000
+#define IXGBE_RXDADV_RSCCNT_SHIFT       17
+#define IXGBE_RXDADV_HDRBUFLEN_SHIFT    5
+#define IXGBE_RXDADV_SPLITHEADER_EN     0x00001000
+#define IXGBE_RXDADV_SPH                0x8000
+
+#define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
+				      IXGBE_RXD_ERR_CE |  \
+				      IXGBE_RXD_ERR_LE |  \
+				      IXGBE_RXD_ERR_PE |  \
+				      IXGBE_RXD_ERR_OSE | \
+				      IXGBE_RXD_ERR_USE)
+
+#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK ( \
+					 IXGBE_RXDADV_ERR_CE |  \
+					 IXGBE_RXDADV_ERR_LE |  \
+					 IXGBE_RXDADV_ERR_PE |  \
+					 IXGBE_RXDADV_ERR_OSE | \
+					 IXGBE_RXDADV_ERR_USE)
+
+#define IXGBE_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
+#define IXGBE_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
+#define IXGBE_TXD_CMD_EOP    0x01000000 /* End of Packet */
+#define IXGBE_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
+#define IXGBE_TXD_CMD_IC     0x04000000 /* Insert Checksum */
+#define IXGBE_TXD_CMD_RS     0x08000000 /* Report Status */
+#define IXGBE_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
+#define IXGBE_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
+#define IXGBE_TXD_STAT_DD    0x00000001 /* Descriptor Done */
+
+/* Transmit Descriptor - Advanced */
+union ixgbe_adv_tx_desc {
+	struct {
+		__le64 buffer_addr;      /* Address of descriptor's data buf */
+		__le32 cmd_type_len;
+		__le32 olinfo_status;
+	} read;
+	struct {
+		__le64 rsvd;       /* Reserved */
+		__le32 nxtseq_seed;
+		__le32 status;
+	} wb;
+};
+
+/* Receive Descriptor - Advanced */
+union ixgbe_adv_rx_desc {
+	struct {
+		__le64 pkt_addr; /* Packet buffer address */
+		__le64 hdr_addr; /* Header buffer address */
+	} read;
+	struct {
+		struct {
+			union {
+				__le32 data;
+				struct {
+					__le16 pkt_info; /* RSS, Pkt type */
+					__le16 hdr_info; /* Splithdr, hdrlen */
+				} hs_rss;
+			} lo_dword;
+			union {
+				__le32 rss; /* RSS Hash */
+				struct {
+					__le16 ip_id; /* IP id */
+					__le16 csum; /* Packet Checksum */
+				} csum_ip;
+			} hi_dword;
+		} lower;
+		struct {
+			__le32 status_error; /* ext status/error */
+			__le16 length; /* Packet length */
+			__le16 vlan; /* VLAN tag */
+		} upper;
+	} wb;  /* writeback */
+};
+
+/* Context descriptors */
+struct ixgbe_adv_tx_context_desc {
+	__le32 vlan_macip_lens;
+	__le32 seqnum_seed;
+	__le32 type_tucmd_mlhl;
+	__le32 mss_l4len_idx;
+};
+
+/* Adv Transmit Descriptor Config Masks */
+#define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
+#define IXGBE_ADVTXD_DTYP_CTXT  0x00200000 /* Advanced Context Desc */
+#define IXGBE_ADVTXD_DTYP_DATA  0x00300000 /* Advanced Data Descriptor */
+#define IXGBE_ADVTXD_DCMD_EOP   IXGBE_TXD_CMD_EOP  /* End of Packet */
+#define IXGBE_ADVTXD_DCMD_IFCS  IXGBE_TXD_CMD_IFCS /* Insert FCS */
+#define IXGBE_ADVTXD_DCMD_RS    IXGBE_TXD_CMD_RS   /* Report Status */
+#define IXGBE_ADVTXD_DCMD_DEXT  IXGBE_TXD_CMD_DEXT /* Desc ext (1=Adv) */
+#define IXGBE_ADVTXD_DCMD_VLE   IXGBE_TXD_CMD_VLE  /* VLAN pkt enable */
+#define IXGBE_ADVTXD_DCMD_TSE   0x80000000 /* TCP Seg enable */
+#define IXGBE_ADVTXD_STAT_DD    IXGBE_TXD_STAT_DD  /* Descriptor Done */
+#define IXGBE_ADVTXD_TUCMD_IPV4      0x00000400  /* IP Packet Type: 1=IPv4 */
+#define IXGBE_ADVTXD_TUCMD_IPV6      0x00000000  /* IP Packet Type: 0=IPv6 */
+#define IXGBE_ADVTXD_TUCMD_L4T_UDP   0x00000000  /* L4 Packet TYPE of UDP */
+#define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
+#define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
+#define IXGBE_ADVTXD_IDX_SHIFT  4 /* Adv desc Index shift */
+#define IXGBE_ADVTXD_POPTS_SHIFT      8  /* Adv desc POPTS shift */
+#define IXGBE_ADVTXD_POPTS_IXSM (IXGBE_TXD_POPTS_IXSM << \
+				 IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_POPTS_TXSM (IXGBE_TXD_POPTS_TXSM << \
+				 IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_PAYLEN_SHIFT    14 /* Adv desc PAYLEN shift */
+#define IXGBE_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
+#define IXGBE_ADVTXD_VLAN_SHIFT      16  /* Adv ctxt vlan tag shift */
+#define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
+#define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
+
+/* Interrupt register bitmasks */
+
+/* Extended Interrupt Cause Read */
+#define IXGBE_EICR_RTX_QUEUE    0x0000FFFF /* RTx Queue Interrupt */
+#define IXGBE_EICR_MAILBOX      0x00080000 /* VF to PF Mailbox Interrupt */
+#define IXGBE_EICR_OTHER        0x80000000 /* Interrupt Cause Active */
+
+/* Extended Interrupt Cause Set */
+#define IXGBE_EICS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EICS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
+#define IXGBE_EICS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
+
+/* Extended Interrupt Mask Set */
+#define IXGBE_EIMS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EIMS_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
+#define IXGBE_EIMS_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
+
+/* Extended Interrupt Mask Clear */
+#define IXGBE_EIMC_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE /* RTx Queue Interrupt */
+#define IXGBE_EIMC_MAILBOX      IXGBE_EICR_MAILBOX   /* VF to PF Mailbox Int */
+#define IXGBE_EIMC_OTHER        IXGBE_EICR_OTHER     /* INT Cause Active */
+
+#define IXGBE_EIMS_ENABLE_MASK ( \
+				IXGBE_EIMS_RTX_QUEUE       | \
+				IXGBE_EIMS_MAILBOX         | \
+				IXGBE_EIMS_OTHER)
+
+#define IXGBE_EITR_CNT_WDIS     0x80000000
+
+/* Error Codes */
+#define IXGBE_ERR_INVALID_MAC_ADDR              -1
+#define IXGBE_ERR_RESET_FAILED                  -2
+
+#endif /* _IXGBEVF_DEFINES_H_ */
diff --git a/drivers/net/ixgbevf/regs.h b/drivers/net/ixgbevf/regs.h
new file mode 100644
index 0000000..12f7596
--- /dev/null
+++ b/drivers/net/ixgbevf/regs.h
@@ -0,0 +1,85 @@
+/*******************************************************************************
+
+  Intel 82599 Virtual Function driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBEVF_REGS_H_
+#define _IXGBEVF_REGS_H_
+
+#define IXGBE_VFCTRL           0x00000
+#define IXGBE_VFSTATUS         0x00008
+#define IXGBE_VFLINKS          0x00010
+#define IXGBE_VFRTIMER         0x00048
+#define IXGBE_VFRXMEMWRAP      0x03190
+#define IXGBE_VTEICR           0x00100
+#define IXGBE_VTEICS           0x00104
+#define IXGBE_VTEIMS           0x00108
+#define IXGBE_VTEIMC           0x0010C
+#define IXGBE_VTEIAC           0x00110
+#define IXGBE_VTEIAM           0x00114
+#define IXGBE_VTEITR(x)        (0x00820 + (4 * x))
+#define IXGBE_VTIVAR(x)        (0x00120 + (4 * x))
+#define IXGBE_VTIVAR_MISC      0x00140
+#define IXGBE_VTRSCINT(x)      (0x00180 + (4 * x))
+#define IXGBE_VFRDBAL(x)       (0x01000 + (0x40 * x))
+#define IXGBE_VFRDBAH(x)       (0x01004 + (0x40 * x))
+#define IXGBE_VFRDLEN(x)       (0x01008 + (0x40 * x))
+#define IXGBE_VFRDH(x)         (0x01010 + (0x40 * x))
+#define IXGBE_VFRDT(x)         (0x01018 + (0x40 * x))
+#define IXGBE_VFRXDCTL(x)      (0x01028 + (0x40 * x))
+#define IXGBE_VFSRRCTL(x)      (0x01014 + (0x40 * x))
+#define IXGBE_VFRSCCTL(x)      (0x0102C + (0x40 * x))
+#define IXGBE_VFPSRTYPE        0x00300
+#define IXGBE_VFTDBAL(x)       (0x02000 + (0x40 * x))
+#define IXGBE_VFTDBAH(x)       (0x02004 + (0x40 * x))
+#define IXGBE_VFTDLEN(x)       (0x02008 + (0x40 * x))
+#define IXGBE_VFTDH(x)         (0x02010 + (0x40 * x))
+#define IXGBE_VFTDT(x)         (0x02018 + (0x40 * x))
+#define IXGBE_VFTXDCTL(x)      (0x02028 + (0x40 * x))
+#define IXGBE_VFTDWBAL(x)      (0x02038 + (0x40 * x))
+#define IXGBE_VFTDWBAH(x)      (0x0203C + (0x40 * x))
+#define IXGBE_VFDCA_RXCTRL(x)  (0x0100C + (0x40 * x))
+#define IXGBE_VFDCA_TXCTRL(x)  (0x0200c + (0x40 * x))
+#define IXGBE_VFGPRC           0x0101C
+#define IXGBE_VFGPTC           0x0201C
+#define IXGBE_VFGORC_LSB       0x01020
+#define IXGBE_VFGORC_MSB       0x01024
+#define IXGBE_VFGOTC_LSB       0x02020
+#define IXGBE_VFGOTC_MSB       0x02024
+#define IXGBE_VFMPRC           0x01034
+
+#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
+
+#define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
+
+#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) ( \
+    writel((value), ((a)->hw_addr + (reg) + ((offset) << 2))))
+
+#define IXGBE_READ_REG_ARRAY(a, reg, offset) ( \
+    readl((a)->hw_addr + (reg) + ((offset) << 2)))
+
+#define IXGBE_WRITE_FLUSH(a) (IXGBE_READ_REG(a, IXGBE_VFSTATUS))
+
+#endif /* _IXGBEVF_REGS_H_ */

