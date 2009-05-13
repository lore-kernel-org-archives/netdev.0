From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/8] ixgbe: Add FCoE feature register defines to
	82599
Date: Wed, 13 May 2009 16:09:39 -0700
Message-ID: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:51608
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580AbZEMXJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 19:09:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds FCoE related register defines to 82599.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |   84 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 9fd79a0..c2d9ed5 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -478,6 +478,63 @@
 #define IXGBE_RTTDTECC_NO_BCN   0x00000100
 #define IXGBE_RTTBCNRC    0x04984
 
+/* FCoE registers */
+#define IXGBE_FCPTRL    0x02410 /* FC User Desc. PTR Low */
+#define IXGBE_FCPTRH    0x02414 /* FC USer Desc. PTR High */
+#define IXGBE_FCBUFF    0x02418 /* FC Buffer Control */
+#define IXGBE_FCDMARW   0x02420 /* FC Receive DMA RW */
+#define IXGBE_FCINVST0  0x03FC0 /* FC Invalid DMA Context Status Reg 0 */
+#define IXGBE_FCINVST(_i)       (IXGBE_FCINVST0 + ((_i) * 4))
+#define IXGBE_FCBUFF_VALID      (1 << 0)   /* DMA Context Valid */
+#define IXGBE_FCBUFF_BUFFSIZE   (3 << 3)   /* User Buffer Size */
+#define IXGBE_FCBUFF_WRCONTX    (1 << 7)   /* 0: Initiator, 1: Target */
+#define IXGBE_FCBUFF_BUFFCNT    0x0000ff00 /* Number of User Buffers */
+#define IXGBE_FCBUFF_OFFSET     0xffff0000 /* User Buffer Offset */
+#define IXGBE_FCBUFF_BUFFSIZE_SHIFT  3
+#define IXGBE_FCBUFF_BUFFCNT_SHIFT   8
+#define IXGBE_FCBUFF_OFFSET_SHIFT    16
+#define IXGBE_FCDMARW_WE        (1 << 14)   /* Write enable */
+#define IXGBE_FCDMARW_RE        (1 << 15)   /* Read enable */
+#define IXGBE_FCDMARW_FCOESEL   0x000001ff  /* FC X_ID: 11 bits */
+#define IXGBE_FCDMARW_LASTSIZE  0xffff0000  /* Last User Buffer Size */
+#define IXGBE_FCDMARW_LASTSIZE_SHIFT 16
+
+/* FCoE SOF/EOF */
+#define IXGBE_TEOFF     0x04A94 /* Tx FC EOF */
+#define IXGBE_TSOFF     0x04A98 /* Tx FC SOF */
+#define IXGBE_REOFF     0x05158 /* Rx FC EOF */
+#define IXGBE_RSOFF     0x051F8 /* Rx FC SOF */
+/* FCoE Filter Context Registers */
+#define IXGBE_FCFLT     0x05108 /* FC FLT Context */
+#define IXGBE_FCFLTRW   0x05110 /* FC Filter RW Control */
+#define IXGBE_FCPARAM   0x051d8 /* FC Offset Parameter */
+#define IXGBE_FCFLT_VALID       (1 << 0)   /* Filter Context Valid */
+#define IXGBE_FCFLT_FIRST       (1 << 1)   /* Filter First */
+#define IXGBE_FCFLT_SEQID       0x00ff0000 /* Sequence ID */
+#define IXGBE_FCFLT_SEQCNT      0xff000000 /* Sequence Count */
+#define IXGBE_FCFLTRW_RVALDT    (1 << 13)  /* Fast Re-Validation */
+#define IXGBE_FCFLTRW_WE        (1 << 14)  /* Write Enable */
+#define IXGBE_FCFLTRW_RE        (1 << 15)  /* Read Enable */
+/* FCoE Receive Control */
+#define IXGBE_FCRXCTRL  0x05100 /* FC Receive Control */
+#define IXGBE_FCRXCTRL_FCOELLI  (1 << 0)   /* Low latency interrupt */
+#define IXGBE_FCRXCTRL_SAVBAD   (1 << 1)   /* Save Bad Frames */
+#define IXGBE_FCRXCTRL_FRSTRDH  (1 << 2)   /* EN 1st Read Header */
+#define IXGBE_FCRXCTRL_LASTSEQH (1 << 3)   /* EN Last Header in Seq */
+#define IXGBE_FCRXCTRL_ALLH     (1 << 4)   /* EN All Headers */
+#define IXGBE_FCRXCTRL_FRSTSEQH (1 << 5)   /* EN 1st Seq. Header */
+#define IXGBE_FCRXCTRL_ICRC     (1 << 6)   /* Ignore Bad FC CRC */
+#define IXGBE_FCRXCTRL_FCCRCBO  (1 << 7)   /* FC CRC Byte Ordering */
+#define IXGBE_FCRXCTRL_FCOEVER  0x00000f00 /* FCoE Version: 4 bits */
+#define IXGBE_FCRXCTRL_FCOEVER_SHIFT 8
+/* FCoE Redirection */
+#define IXGBE_FCRECTL   0x0ED00 /* FC Redirection Control */
+#define IXGBE_FCRETA0   0x0ED10 /* FC Redirection Table 0 */
+#define IXGBE_FCRETA(_i)        (IXGBE_FCRETA0 + ((_i) * 4)) /* FCoE Redir */
+#define IXGBE_FCRECTL_ENA       0x1        /* FCoE Redir Table Enable */
+#define IXGBE_FCRETA_SIZE       8          /* Max entries in FCRETA */
+#define IXGBE_FCRETA_ENTRY_MASK 0x0000007f /* 7 bits for the queue index */
+
 /* Stats registers */
 #define IXGBE_CRCERRS   0x04000
 #define IXGBE_ILLERRC   0x04004
@@ -549,6 +606,13 @@
 #define IXGBE_QPRDC(_i) (0x01430 + ((_i) * 0x40)) /* 16 of these */
 #define IXGBE_QBTC_L(_i) (0x08700 + ((_i) * 0x8)) /* 16 of these */
 #define IXGBE_QBTC_H(_i) (0x08704 + ((_i) * 0x8)) /* 16 of these */
+#define IXGBE_FCCRC     0x05118 /* Count of Good Eth CRC w/ Bad FC CRC */
+#define IXGBE_FCOERPDC  0x0241C /* FCoE Rx Packets Dropped Count */
+#define IXGBE_FCLAST    0x02424 /* FCoE Last Error Count */
+#define IXGBE_FCOEPRC   0x02428 /* Number of FCoE Packets Received */
+#define IXGBE_FCOEDWRC  0x0242C /* Number of FCoE DWords Received */
+#define IXGBE_FCOEPTC   0x08784 /* Number of FCoE Packets Transmitted */
+#define IXGBE_FCOEDWTC  0x08788 /* Number of FCoE DWords Transmitted */
 
 /* Management */
 #define IXGBE_MAVTV(_i) (0x05010 + ((_i) * 4)) /* 8 of these (0-7) */
@@ -1153,6 +1217,7 @@
 
 /* ETYPE Queue Filter/Select Bit Masks */
 #define IXGBE_MAX_ETQF_FILTERS  8
+#define IXGBE_ETQF_FCOE         0x08000000 /* bit 27 */
 #define IXGBE_ETQF_BCN          0x10000000 /* bit 28 */
 #define IXGBE_ETQF_1588         0x40000000 /* bit 30 */
 #define IXGBE_ETQF_FILTER_EN    0x80000000 /* bit 31 */
@@ -1175,6 +1240,7 @@
  */
 #define IXGBE_ETQF_FILTER_EAPOL          0
 #define IXGBE_ETQF_FILTER_BCN            1
+#define IXGBE_ETQF_FILTER_FCOE           2
 #define IXGBE_ETQF_FILTER_1588           3
 /* VLAN Control Bit Masks */
 #define IXGBE_VLNCTRL_VET       0x0000FFFF  /* bits 0-15 */
@@ -1579,6 +1645,8 @@
 #define IXGBE_RXD_ERR_IPE       0x80    /* IP Checksum Error */
 #define IXGBE_RXDADV_ERR_MASK           0xfff00000 /* RDESC.ERRORS mask */
 #define IXGBE_RXDADV_ERR_SHIFT          20         /* RDESC.ERRORS shift */
+#define IXGBE_RXDADV_ERR_FCEOFE         0x80000000 /* FCoEFe/IPE */
+#define IXGBE_RXDADV_ERR_FCERR          0x00700000 /* FCERR/FDIRERR */
 #define IXGBE_RXDADV_ERR_HBO    0x00800000 /*Header Buffer Overflow */
 #define IXGBE_RXDADV_ERR_CE     0x01000000 /* CRC Error */
 #define IXGBE_RXDADV_ERR_LE     0x02000000 /* Length Error */
@@ -1598,6 +1666,12 @@
 #define IXGBE_RXDADV_STAT_FLM           IXGBE_RXD_STAT_FLM /* FDir Match */
 #define IXGBE_RXDADV_STAT_VP            IXGBE_RXD_STAT_VP  /* IEEE VLAN Pkt */
 #define IXGBE_RXDADV_STAT_MASK          0x000fffff /* Stat/NEXTP: bit 0-19 */
+#define IXGBE_RXDADV_STAT_FCEOFS        0x00000040 /* FCoE EOF/SOF Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT        0x00000030 /* FCoE Pkt Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT_NOMTCH 0x00000000 /* 00: No Ctxt Match */
+#define IXGBE_RXDADV_STAT_FCSTAT_NODDP  0x00000010 /* 01: Ctxt w/o DDP */
+#define IXGBE_RXDADV_STAT_FCSTAT_FCPRSP 0x00000020 /* 10: Recv. FCP_RSP */
+#define IXGBE_RXDADV_STAT_FCSTAT_DDP    0x00000030 /* 11: Ctxt w/ DDP */
 
 /* PSRTYPE bit definitions */
 #define IXGBE_PSRTYPE_TCPHDR    0x00000010
@@ -1831,6 +1905,16 @@ struct ixgbe_adv_tx_context_desc {
 #define IXGBE_ADVTXD_POPTS_IPSEC      0x00000400 /* IPSec offload request */
 #define IXGBE_ADVTXD_TUCMD_IPSEC_TYPE_ESP 0x00002000 /* IPSec Type ESP */
 #define IXGBE_ADVTXD_TUCMD_IPSEC_ENCRYPT_EN 0x00004000/* ESP Encrypt Enable */
+#define IXGBE_ADVTXT_TUCMD_FCOE      0x00008000       /* FCoE Frame Type */
+#define IXGBE_ADVTXD_FCOEF_EOF_MASK  (0x3 << 10)      /* FC EOF index */
+#define IXGBE_ADVTXD_FCOEF_SOF       ((1 << 2) << 10) /* FC SOF index */
+#define IXGBE_ADVTXD_FCOEF_PARINC    ((1 << 3) << 10) /* Rel_Off in F_CTL */
+#define IXGBE_ADVTXD_FCOEF_ORIE      ((1 << 4) << 10) /* Orientation: End */
+#define IXGBE_ADVTXD_FCOEF_ORIS      ((1 << 5) << 10) /* Orientation: Start */
+#define IXGBE_ADVTXD_FCOEF_EOF_N     (0x0 << 10)      /* 00: EOFn */
+#define IXGBE_ADVTXD_FCOEF_EOF_T     (0x1 << 10)      /* 01: EOFt */
+#define IXGBE_ADVTXD_FCOEF_EOF_NI    (0x2 << 10)      /* 10: EOFni */
+#define IXGBE_ADVTXD_FCOEF_EOF_A     (0x3 << 10)      /* 11: EOFa */
 #define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
 #define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
 

