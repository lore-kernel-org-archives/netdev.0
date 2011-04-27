From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/12] ixgbe: register defines cleanup
Date: Wed, 27 Apr 2011 02:34:42 -0700
Message-ID: <1303896891-16006-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034Ab1D0JfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:00 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Remove duplicates.
Fix incorrect defines.
Fix/Update comments.
Fix whitespace.
Add new register defines.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_mbx.h  |    3 -
 drivers/net/ixgbe/ixgbe_type.h |  189 ++++++++++++++++++++++++++--------------
 2 files changed, 125 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index fe6ea81..f53dc5b 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -36,9 +36,6 @@
 #define IXGBE_VFMAILBOX             0x002FC
 #define IXGBE_VFMBMEM               0x00200
 
-#define IXGBE_PFMAILBOX(x)          (0x04B00 + (4 * x))
-#define IXGBE_PFMBMEM(vfn)          (0x13000 + (64 * vfn))
-
 #define IXGBE_PFMAILBOX_STS   0x00000001 /* Initiate message send to VF */
 #define IXGBE_PFMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
 #define IXGBE_PFMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f5bec97..fab9737 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -164,6 +164,9 @@
                          (0x0D018 + ((_i - 64) * 0x40)))
 #define IXGBE_RXDCTL(_i) (((_i) < 64) ? (0x01028 + ((_i) * 0x40)) : \
                           (0x0D028 + ((_i - 64) * 0x40)))
+#define IXGBE_RSCCTL(_i) (((_i) < 64) ? (0x0102C + ((_i) * 0x40)) : \
+                          (0x0D02C + ((_i - 64) * 0x40)))
+#define IXGBE_RSCDBU     0x03028
 #define IXGBE_RDDCC      0x02F20
 #define IXGBE_RXMEMWRAP  0x03190
 #define IXGBE_STARCTRL   0x03024
@@ -228,17 +231,23 @@
 #define IXGBE_VLVF(_i)  (0x0F100 + ((_i) * 4))  /* 64 of these (0-63) */
 #define IXGBE_VLVFB(_i) (0x0F200 + ((_i) * 4))  /* 128 of these (0-127) */
 #define IXGBE_VMVIR(_i) (0x08000 + ((_i) * 4))  /* 64 of these (0-63) */
-#define IXGBE_VT_CTL    0x051B0
-#define IXGBE_VFRE(_i)  (0x051E0 + ((_i) * 4))
-#define IXGBE_VFTE(_i)  (0x08110 + ((_i) * 4))
-#define IXGBE_VMECM(_i) (0x08790 + ((_i) * 4))
-#define IXGBE_QDE       0x2F04
-#define IXGBE_VMOLR(_i) (0x0F000 + ((_i) * 4)) /* 64 total */
-#define IXGBE_UTA(_i)   (0x0F400 + ((_i) * 4))
-#define IXGBE_VMRCTL(_i)        (0x0F600 + ((_i) * 4))
-#define IXGBE_VMRVLAN(_i)       (0x0F610 + ((_i) * 4))
-#define IXGBE_VMRVM(_i)         (0x0F630 + ((_i) * 4))
-#define IXGBE_L34T_IMIR(_i)      (0x0E800 + ((_i) * 4)) /*128 of these (0-127)*/
+#define IXGBE_VT_CTL         0x051B0
+#define IXGBE_PFMAILBOX(_i)  (0x04B00 + (4 * (_i))) /* 64 total */
+#define IXGBE_PFMBMEM(_i)    (0x13000 + (64 * (_i))) /* 64 Mailboxes, 16 DW each */
+#define IXGBE_PFMBICR(_i)    (0x00710 + (4 * (_i))) /* 4 total */
+#define IXGBE_PFMBIMR(_i)    (0x00720 + (4 * (_i))) /* 4 total */
+#define IXGBE_VFRE(_i)       (0x051E0 + ((_i) * 4))
+#define IXGBE_VFTE(_i)       (0x08110 + ((_i) * 4))
+#define IXGBE_VMECM(_i)      (0x08790 + ((_i) * 4))
+#define IXGBE_QDE            0x2F04
+#define IXGBE_VMTXSW(_i)     (0x05180 + ((_i) * 4)) /* 2 total */
+#define IXGBE_VMOLR(_i)      (0x0F000 + ((_i) * 4)) /* 64 total */
+#define IXGBE_UTA(_i)        (0x0F400 + ((_i) * 4))
+#define IXGBE_MRCTL(_i)      (0x0F600 + ((_i) * 4))
+#define IXGBE_VMRVLAN(_i)    (0x0F610 + ((_i) * 4))
+#define IXGBE_VMRVM(_i)      (0x0F630 + ((_i) * 4))
+#define IXGBE_L34T_IMIR(_i)  (0x0E800 + ((_i) * 4)) /*128 of these (0-127)*/
+#define IXGBE_RXFECCERR0         0x051B8
 #define IXGBE_LLITHRESH 0x0EC90
 #define IXGBE_IMIR(_i)  (0x05A80 + ((_i) * 4))  /* 8 of these (0-7) */
 #define IXGBE_IMIREXT(_i)       (0x05AA0 + ((_i) * 4))  /* 8 of these (0-7) */
@@ -365,7 +374,7 @@
 #define IXGBE_WUFC_FLX5 0x00200000 /* Flexible Filter 5 Enable */
 #define IXGBE_WUFC_FLX_FILTERS     0x000F0000 /* Mask for 4 flex filters */
 #define IXGBE_WUFC_EXT_FLX_FILTERS 0x00300000 /* Mask for Ext. flex filters */
-#define IXGBE_WUFC_ALL_FILTERS     0x003F00FF /* Mask for all 6 wakeup filters*/
+#define IXGBE_WUFC_ALL_FILTERS     0x003F00FF /* Mask for all wakeup filters */
 #define IXGBE_WUFC_FLX_OFFSET      16 /* Offset to the Flexible Filters bits */
 
 /* Wake Up Status */
@@ -407,7 +416,6 @@
 #define IXGBE_SECTXSTAT         0x08804
 #define IXGBE_SECTXBUFFAF       0x08808
 #define IXGBE_SECTXMINIFG       0x08810
-#define IXGBE_SECTXSTAT         0x08804
 #define IXGBE_SECRXCTRL         0x08D00
 #define IXGBE_SECRXSTAT         0x08D04
 
@@ -500,21 +508,6 @@
 
 #define IXGBE_SECTXCTRL_STORE_FORWARD_ENABLE    0x4
 
-/* HW RSC registers */
-#define IXGBE_RSCCTL(_i) (((_i) < 64) ? (0x0102C + ((_i) * 0x40)) : \
-                          (0x0D02C + ((_i - 64) * 0x40)))
-#define IXGBE_RSCDBU      0x03028
-#define IXGBE_RSCCTL_RSCEN          0x01
-#define IXGBE_RSCCTL_MAXDESC_1      0x00
-#define IXGBE_RSCCTL_MAXDESC_4      0x04
-#define IXGBE_RSCCTL_MAXDESC_8      0x08
-#define IXGBE_RSCCTL_MAXDESC_16     0x0C
-#define IXGBE_RXDADV_RSCCNT_SHIFT     17
-#define IXGBE_GPIE_RSC_DELAY_SHIFT    11
-#define IXGBE_RXDADV_RSCCNT_MASK    0x001E0000
-#define IXGBE_RSCDBU_RSCACKDIS      0x00000080
-#define IXGBE_RDRXCTL_RSCFRSTSIZE   0x003E0000
-
 /* DCB registers */
 #define IXGBE_RTRPCS      0x02430
 #define IXGBE_RTTDCS      0x04900
@@ -523,6 +516,7 @@
 #define IXGBE_RTRUP2TC    0x03020
 #define IXGBE_RTTUP2TC    0x0C800
 #define IXGBE_RTRPT4C(_i) (0x02140 + ((_i) * 4)) /* 8 of these (0-7) */
+#define IXGBE_TXLLQ(_i)   (0x082E0 + ((_i) * 4)) /* 4 of these (0-3) */
 #define IXGBE_RTRPT4S(_i) (0x02160 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_RTTDT2C(_i) (0x04910 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_RTTDT2S(_i) (0x04930 + ((_i) * 4)) /* 8 of these (0-7) */
@@ -541,7 +535,7 @@
 	(IXGBE_RTTBCNRC_RF_DEC_MASK << IXGBE_RTTBCNRC_RF_INT_SHIFT)
 
 
-/* FCoE registers */
+/* FCoE DMA Context Registers */
 #define IXGBE_FCPTRL    0x02410 /* FC User Desc. PTR Low */
 #define IXGBE_FCPTRH    0x02414 /* FC USer Desc. PTR High */
 #define IXGBE_FCBUFF    0x02418 /* FC Buffer Control */
@@ -743,17 +737,10 @@
 #define IXGBE_PBACLR_82599      0x11068
 #define IXGBE_CIAA_82599        0x11088
 #define IXGBE_CIAD_82599        0x1108C
-#define IXGBE_PCIE_DIAG_0_82599 0x11090
-#define IXGBE_PCIE_DIAG_1_82599 0x11094
-#define IXGBE_PCIE_DIAG_2_82599 0x11098
-#define IXGBE_PCIE_DIAG_3_82599 0x1109C
-#define IXGBE_PCIE_DIAG_4_82599 0x110A0
-#define IXGBE_PCIE_DIAG_5_82599 0x110A4
-#define IXGBE_PCIE_DIAG_6_82599 0x110A8
-#define IXGBE_PCIE_DIAG_7_82599 0x110C0
-#define IXGBE_INTRPT_CSR_82599  0x110B0
-#define IXGBE_INTRPT_MASK_82599 0x110B8
+#define IXGBE_PICAUSE           0x110B0
+#define IXGBE_PIENA             0x110B8
 #define IXGBE_CDQ_MBR_82599     0x110B4
+#define IXGBE_PCIESPARE         0x110BC
 #define IXGBE_MISC_REG_82599    0x110F0
 #define IXGBE_ECC_CTRL_0_82599  0x11100
 #define IXGBE_ECC_CTRL_1_82599  0x11104
@@ -786,7 +773,19 @@
 #define IXGBE_SYSTIML    0x08C0C /* System time register Low - RO */
 #define IXGBE_SYSTIMH    0x08C10 /* System time register High - RO */
 #define IXGBE_TIMINCA    0x08C14 /* Increment attributes register - RW */
-#define IXGBE_RXUDP      0x08C1C /* Time Sync Rx UDP Port - RW */
+#define IXGBE_TIMADJL    0x08C18 /* Time Adjustment Offset register Low - RW */
+#define IXGBE_TIMADJH    0x08C1C /* Time Adjustment Offset register High - RW */
+#define IXGBE_TSAUXC     0x08C20 /* TimeSync Auxiliary Control register - RW */
+#define IXGBE_TRGTTIML0  0x08C24 /* Target Time Register 0 Low - RW */
+#define IXGBE_TRGTTIMH0  0x08C28 /* Target Time Register 0 High - RW */
+#define IXGBE_TRGTTIML1  0x08C2C /* Target Time Register 1 Low - RW */
+#define IXGBE_TRGTTIMH1  0x08C30 /* Target Time Register 1 High - RW */
+#define IXGBE_FREQOUT0   0x08C34 /* Frequency Out 0 Control register - RW */
+#define IXGBE_FREQOUT1   0x08C38 /* Frequency Out 1 Control register - RW */
+#define IXGBE_AUXSTMPL0  0x08C3C /* Auxiliary Time Stamp 0 register Low - RO */
+#define IXGBE_AUXSTMPH0  0x08C40 /* Auxiliary Time Stamp 0 register High - RO */
+#define IXGBE_AUXSTMPL1  0x08C44 /* Auxiliary Time Stamp 1 register Low - RO */
+#define IXGBE_AUXSTMPH1  0x08C48 /* Auxiliary Time Stamp 1 register High - RO */
 
 /* Diagnostic Registers */
 #define IXGBE_RDSTATCTL   0x02C20
@@ -830,8 +829,20 @@
 #define IXGBE_TXDATARDPTR(_i)   (0x0C720 + ((_i) * 4)) /* 8 of these C720-C72C*/
 #define IXGBE_TXDESCRDPTR(_i)   (0x0C730 + ((_i) * 4)) /* 8 of these C730-C73C*/
 #define IXGBE_PCIEECCCTL 0x1106C
+#define IXGBE_RXWRPTR(_i)       (0x03100 + ((_i) * 4)) /* 8 of these 3100-310C*/
+#define IXGBE_RXUSED(_i)        (0x03120 + ((_i) * 4)) /* 8 of these 3120-312C*/
+#define IXGBE_RXRDPTR(_i)       (0x03140 + ((_i) * 4)) /* 8 of these 3140-314C*/
+#define IXGBE_RXRDWRPTR(_i)     (0x03160 + ((_i) * 4)) /* 8 of these 3160-310C*/
+#define IXGBE_TXWRPTR(_i)       (0x0C100 + ((_i) * 4)) /* 8 of these C100-C10C*/
+#define IXGBE_TXUSED(_i)        (0x0C120 + ((_i) * 4)) /* 8 of these C120-C12C*/
+#define IXGBE_TXRDPTR(_i)       (0x0C140 + ((_i) * 4)) /* 8 of these C140-C14C*/
+#define IXGBE_TXRDWRPTR(_i)     (0x0C160 + ((_i) * 4)) /* 8 of these C160-C10C*/
 #define IXGBE_PCIEECCCTL0 0x11100
 #define IXGBE_PCIEECCCTL1 0x11104
+#define IXGBE_RXDBUECC  0x03F70
+#define IXGBE_TXDBUECC  0x0CF70
+#define IXGBE_RXDBUEST 0x03F74
+#define IXGBE_TXDBUEST 0x0CF74
 #define IXGBE_PBTXECC   0x0C300
 #define IXGBE_PBRXECC   0x03300
 #define IXGBE_GHECCR    0x110B0
@@ -872,6 +883,7 @@
 #define IXGBE_AUTOC3    0x042AC
 #define IXGBE_ANLP1     0x042B0
 #define IXGBE_ANLP2     0x042B4
+#define IXGBE_MACC      0x04330
 #define IXGBE_ATLASCTL  0x04800
 #define IXGBE_MMNGC     0x042D0
 #define IXGBE_ANLPNP1   0x042D4
@@ -884,14 +896,49 @@
 #define IXGBE_MPVC      0x04318
 #define IXGBE_SGMIIC    0x04314
 
+/* Statistics Registers */
+#define IXGBE_RXNFGPC      0x041B0
+#define IXGBE_RXNFGBCL     0x041B4
+#define IXGBE_RXNFGBCH     0x041B8
+#define IXGBE_RXDGPC       0x02F50
+#define IXGBE_RXDGBCL      0x02F54
+#define IXGBE_RXDGBCH      0x02F58
+#define IXGBE_RXDDGPC      0x02F5C
+#define IXGBE_RXDDGBCL     0x02F60
+#define IXGBE_RXDDGBCH     0x02F64
+#define IXGBE_RXLPBKGPC    0x02F68
+#define IXGBE_RXLPBKGBCL   0x02F6C
+#define IXGBE_RXLPBKGBCH   0x02F70
+#define IXGBE_RXDLPBKGPC   0x02F74
+#define IXGBE_RXDLPBKGBCL  0x02F78
+#define IXGBE_RXDLPBKGBCH  0x02F7C
+#define IXGBE_TXDGPC       0x087A0
+#define IXGBE_TXDGBCL      0x087A4
+#define IXGBE_TXDGBCH      0x087A8
+
+#define IXGBE_RXDSTATCTRL 0x02F40
+
+/* Copper Pond 2 link timeout */
 #define IXGBE_VALIDATE_LINK_READY_TIMEOUT 50
 
 /* Omer CORECTL */
 #define IXGBE_CORECTL           0x014F00
 /* BARCTRL */
-#define IXGBE_BARCTRL           0x110F4
-#define IXGBE_BARCTRL_FLSIZE    0x0700
-#define IXGBE_BARCTRL_CSRSIZE   0x2000
+#define IXGBE_BARCTRL               0x110F4
+#define IXGBE_BARCTRL_FLSIZE        0x0700
+#define IXGBE_BARCTRL_FLSIZE_SHIFT  8
+#define IXGBE_BARCTRL_CSRSIZE       0x2000
+
+/* RSCCTL Bit Masks */
+#define IXGBE_RSCCTL_RSCEN          0x01
+#define IXGBE_RSCCTL_MAXDESC_1      0x00
+#define IXGBE_RSCCTL_MAXDESC_4      0x04
+#define IXGBE_RSCCTL_MAXDESC_8      0x08
+#define IXGBE_RSCCTL_MAXDESC_16     0x0C
+
+/* RSCDBU Bit Masks */
+#define IXGBE_RSCDBU_RSCSMALDIS_MASK    0x0000007F
+#define IXGBE_RSCDBU_RSCACKDIS          0x00000080
 
 /* RDRXCTL Bit Masks */
 #define IXGBE_RDRXCTL_RDMTS_1_2     0x00000000 /* Rx Desc Min Threshold Size */
@@ -899,6 +946,8 @@
 #define IXGBE_RDRXCTL_MVMEN         0x00000020
 #define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done */
 #define IXGBE_RDRXCTL_AGGDIS        0x00010000 /* Aggregation disable */
+#define IXGBE_RDRXCTL_RSCFRSTSIZE   0x003E0000 /* RSC First packet size */
+#define IXGBE_RDRXCTL_RSCLLIDIS     0x00800000 /* Disable RSC compl on LLI */
 #define IXGBE_RDRXCTL_RSCACKC       0x02000000 /* must set 1 when RSC enabled */
 #define IXGBE_RDRXCTL_FCOE_WRFIX    0x04000000 /* must set 1 when RSC enabled */
 
@@ -970,8 +1019,8 @@
 #define IXGBE_MSCA_OP_CODE_SHIFT     26 /* OP CODE shift */
 #define IXGBE_MSCA_ADDR_CYCLE        0x00000000 /* OP CODE 00 (addr cycle) */
 #define IXGBE_MSCA_WRITE             0x04000000 /* OP CODE 01 (write) */
-#define IXGBE_MSCA_READ              0x08000000 /* OP CODE 10 (read) */
-#define IXGBE_MSCA_READ_AUTOINC      0x0C000000 /* OP CODE 11 (read, auto inc)*/
+#define IXGBE_MSCA_READ              0x0C000000 /* OP CODE 11 (read) */
+#define IXGBE_MSCA_READ_AUTOINC      0x08000000 /* OP CODE 10 (read, auto inc)*/
 #define IXGBE_MSCA_ST_CODE_MASK      0x30000000 /* ST Code mask */
 #define IXGBE_MSCA_ST_CODE_SHIFT     28 /* ST Code shift */
 #define IXGBE_MSCA_NEW_PROTOCOL      0x00000000 /* ST CODE 00 (new protocol) */
@@ -1058,6 +1107,7 @@
 #define IXGBE_GPIE_EIMEN         0x00000040 /* Immediate Interrupt Enable */
 #define IXGBE_GPIE_EIAME         0x40000000
 #define IXGBE_GPIE_PBA_SUPPORT   0x80000000
+#define IXGBE_GPIE_RSC_DELAY_SHIFT 11
 #define IXGBE_GPIE_VTMODE_MASK   0x0000C000 /* VT Mode Mask */
 #define IXGBE_GPIE_VTMODE_16     0x00004000 /* 16 VFs 8 queues per VF */
 #define IXGBE_GPIE_VTMODE_32     0x00008000 /* 32 VFs 4 queues per VF */
@@ -1292,6 +1342,11 @@
 #define IXGBE_FTQF_POOL_SHIFT           8
 #define IXGBE_FTQF_5TUPLE_MASK_MASK     0x0000001F
 #define IXGBE_FTQF_5TUPLE_MASK_SHIFT    25
+#define IXGBE_FTQF_SOURCE_ADDR_MASK     0x1E
+#define IXGBE_FTQF_DEST_ADDR_MASK       0x1D
+#define IXGBE_FTQF_SOURCE_PORT_MASK     0x1B
+#define IXGBE_FTQF_DEST_PORT_MASK       0x17
+#define IXGBE_FTQF_PROTOCOL_COMP_MASK   0x0F
 #define IXGBE_FTQF_POOL_MASK_EN         0x40000000
 #define IXGBE_FTQF_QUEUE_ENABLE         0x80000000
 
@@ -1334,11 +1389,11 @@
  *
  * Current filters:
  *    EAPOL 802.1x (0x888e): Filter 0
- *    BCN (0x8904):          Filter 1
+ *    FCoE (0x8906):         Filter 2
  *    1588 (0x88f7):         Filter 3
+ *    FIP  (0x8914):         Filter 4
  */
 #define IXGBE_ETQF_FILTER_EAPOL          0
-#define IXGBE_ETQF_FILTER_BCN            1
 #define IXGBE_ETQF_FILTER_FCOE           2
 #define IXGBE_ETQF_FILTER_1588           3
 #define IXGBE_ETQF_FILTER_FIP            4
@@ -1449,6 +1504,11 @@
 #define IXGBE_AUTOC2_10G_XFI (0x1 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC2_10G_SFI (0x2 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 
+#define IXGBE_MACC_FLU       0x00000001
+#define IXGBE_MACC_FSV_10G   0x00030000
+#define IXGBE_MACC_FS        0x00040000
+#define IXGBE_MAC_RX2TX_LPBK 0x00000002
+
 /* LINKS Bit Masks */
 #define IXGBE_LINKS_KX_AN_COMP  0x80000000
 #define IXGBE_LINKS_UP          0x40000000
@@ -1502,7 +1562,6 @@
 #define IXGBE_ANLP1_ASM_PAUSE           0x0800
 #define IXGBE_ANLP1_AN_STATE_MASK       0x000f0000
 
-
 /* SW Semaphore Register bitmasks */
 #define IXGBE_SWSM_SMBI 0x00000001 /* Driver Semaphore bit */
 #define IXGBE_SWSM_SWESMBI 0x00000002 /* FW Semaphore bit */
@@ -1515,6 +1574,10 @@
 #define IXGBE_GSSR_PHY1_SM    0x0004
 #define IXGBE_GSSR_MAC_CSR_SM 0x0008
 #define IXGBE_GSSR_FLASH_SM   0x0010
+#define IXGBE_GSSR_SW_MNG_SM  0x0400
+
+/* FW Status register bitmask */
+#define IXGBE_FWSTS_FWRI    0x00000200 /* Firmware Reset Indication */
 
 /* EEC Register */
 #define IXGBE_EEC_SK        0x00000001 /* EEPROM Clock */
@@ -1535,6 +1598,7 @@
 /* EEPROM Addressing bits based on type (0-small, 1-large) */
 #define IXGBE_EEC_ADDR_SIZE 0x00000400
 #define IXGBE_EEC_SIZE      0x00007800 /* EEPROM Size */
+#define IXGBE_EERD_MAX_ADDR 0x00003FFF /* EERD alows 14 bits for addr. */
 
 #define IXGBE_EEC_SIZE_SHIFT          11
 #define IXGBE_EEPROM_WORD_SIZE_SHIFT  6
@@ -1564,8 +1628,10 @@
 #define IXGBE_FW_PTR            0x0F
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
-#define IXGBE_DEVICE_CAPS       0x2C
+#define IXGBE_FREE_SPACE_PTR    0X3E
 #define IXGBE_SAN_MAC_ADDR_PTR  0x28
+#define IXGBE_DEVICE_CAPS       0x2C
+#define IXGBE_SERIAL_NUMBER_MAC_ADDR 0x11
 #define IXGBE_PCIE_MSIX_82599_CAPS  0x72
 #define IXGBE_PCIE_MSIX_82598_CAPS  0x62
 
@@ -1630,9 +1696,12 @@
 #define IXGBE_FW_LESM_STATE_1            0x1
 #define IXGBE_FW_LESM_STATE_ENABLED      0x8000 /* LESM Enable bit */
 #define IXGBE_FW_PASSTHROUGH_PATCH_CONFIG_PTR   0x4
-#define IXGBE_FW_PATCH_VERSION_4   0x7
-
-/* Alternative SAN MAC Address Block */
+#define IXGBE_FW_PATCH_VERSION_4         0x7
+#define IXGBE_FCOE_IBA_CAPS_BLK_PTR         0x33 /* iSCSI/FCOE block */
+#define IXGBE_FCOE_IBA_CAPS_FCOE            0x20 /* FCOE flags */
+#define IXGBE_ISCSI_FCOE_BLK_PTR            0x17 /* iSCSI/FCOE block */
+#define IXGBE_ISCSI_FCOE_FLAGS_OFFSET       0x0  /* FCOE flags */
+#define IXGBE_ISCSI_FCOE_FLAGS_ENABLE       0x1  /* FCOE flags enable bit */
 #define IXGBE_ALT_SAN_MAC_ADDR_BLK_PTR      0x27 /* Alt. SAN MAC block */
 #define IXGBE_ALT_SAN_MAC_ADDR_CAPS_OFFSET  0x0 /* Alt. SAN MAC capability */
 #define IXGBE_ALT_SAN_MAC_ADDR_PORT0_OFFSET 0x1 /* Alt. SAN MAC 0 offset */
@@ -1697,6 +1766,7 @@
 /* Transmit Config masks */
 #define IXGBE_TXDCTL_ENABLE     0x02000000 /* Enable specific Tx Queue */
 #define IXGBE_TXDCTL_SWFLSH     0x04000000 /* Tx Desc. write-back flushing */
+#define IXGBE_TXDCTL_WTHRESH_SHIFT      16 /* shift to WTHRESH bits */
 /* Enable short packet padding to 64 bytes */
 #define IXGBE_TX_PAD_ENABLE     0x00000400
 #define IXGBE_JUMBO_FRAME_ENABLE 0x00000004  /* Allow jumbo frames */
@@ -1710,9 +1780,9 @@
 #define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
 #define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
 #define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
-#define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
 #define IXGBE_RXDCTL_RLPMLMASK  0x00003FFF  /* Only supported on the X540 */
 #define IXGBE_RXDCTL_RLPML_EN   0x00008000
+#define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
 
 #define IXGBE_FCTRL_SBP 0x00000002 /* Store Bad Packet */
 #define IXGBE_FCTRL_MPE 0x00000100 /* Multicast Promiscuous Ena*/
@@ -1870,6 +1940,8 @@
 #define IXGBE_RXDADV_PKTTYPE_MASK       0x0000FFF0
 #define IXGBE_RXDADV_PKTTYPE_MASK_EX    0x0001FFF0
 #define IXGBE_RXDADV_HDRBUFLEN_MASK     0x00007FE0
+#define IXGBE_RXDADV_RSCCNT_MASK        0x001E0000
+#define IXGBE_RXDADV_RSCCNT_SHIFT       17
 #define IXGBE_RXDADV_HDRBUFLEN_SHIFT    5
 #define IXGBE_RXDADV_SPLITHEADER_EN     0x00001000
 #define IXGBE_RXDADV_SPH                0x8000
@@ -1945,15 +2017,6 @@
 #define IXGBE_VFLRE(_i)                  (((_i & 1) ? 0x001C0 : 0x00600))
 #define IXGBE_VFLREC(_i)                 (0x00700 + (_i * 4))
 
-/* Little Endian defines */
-#ifndef __le32
-#define __le32  u32
-#endif
-#ifndef __le64
-#define __le64  u64
-
-#endif
-
 enum ixgbe_fdir_pballoc_type {
 	IXGBE_FDIR_PBALLOC_64K = 0,
 	IXGBE_FDIR_PBALLOC_128K,
@@ -2152,8 +2215,6 @@ typedef u32 ixgbe_link_speed;
                                         IXGBE_LINK_SPEED_1GB_FULL | \
                                         IXGBE_LINK_SPEED_10GB_FULL)
 
-#define IXGBE_PCIE_DEV_CTRL_2 0xC8
-#define PCIE_COMPL_TO_VALUE 0x05
 
 /* Physical layer type */
 typedef u32 ixgbe_physical_layer;
-- 
1.7.4.4

