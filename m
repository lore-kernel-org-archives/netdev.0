From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/4] igb: add more register
	definitions for time sync functions.
Date: Mon, 27 May 2013 11:21:43 +0200
Message-ID: <a5df1f05bf9734924969c25879d177c9b16924ea.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Jacob Keller <jacob.e.keller@intel.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch adds missing definitions needed for implementing the
auxiliary time sync functions.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |   68 ++++++++++++++++++++++--
 drivers/net/ethernet/intel/igb/e1000_regs.h    |    9 ++++
 drivers/net/ethernet/intel/igb/igb_ptp.c       |    4 +-
 3 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index aa201ab..7451f42 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -44,7 +44,10 @@
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
 
 /* Extended Device Control */
+#define E1000_CTRL_EXT_SDP2_DATA 0x00000040 /* Value of SW Defineable Pin 2 */
 #define E1000_CTRL_EXT_SDP3_DATA 0x00000080 /* Value of SW Defineable Pin 3 */
+#define E1000_CTRL_EXT_SDP2_DIR  0x00000400 /* SDP2 data direction */
+#define E1000_CTRL_EXT_SDP3_DIR  0x00000800 /* SDP3 data direction */
 /* Physical Func Reset Done Indication */
 #define E1000_CTRL_EXT_PFRSTD    0x00004000
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
@@ -191,7 +194,8 @@
 /* enable link status from external LINK_0 and LINK_1 pins */
 #define E1000_CTRL_SWDPIN0  0x00040000  /* SWDPIN 0 value */
 #define E1000_CTRL_SWDPIN1  0x00080000  /* SWDPIN 1 value */
-#define E1000_CTRL_SWDPIO0  0x00400000  /* SWDPIN 0 Input or output */
+#define E1000_CTRL_SDP0_DIR 0x00400000  /* SDP0 data direction */
+#define E1000_CTRL_SDP1_DIR 0x00800000  /* SDP1 data direction */
 #define E1000_CTRL_RST      0x04000000  /* Global reset */
 #define E1000_CTRL_RFCE     0x08000000  /* Receive Flow Control enable */
 #define E1000_CTRL_TFCE     0x10000000  /* Transmit flow control enable */
@@ -524,8 +528,66 @@
 
 #define E1000_TIMINCA_16NS_SHIFT 24
 
-#define E1000_TSICR_TXTS 0x00000002
-#define E1000_TSIM_TXTS 0x00000002
+/* Time Sync Interrupt Cause/Mask Regsiter Bits */
+#define TSINTR_SYS_WRAP  (1 << 0) /* SYSTIM Wrap around. */
+#define TSINTR_TXTS      (1 << 1) /* Transmit Timestamp. */
+#define TSINTR_RXTS      (1 << 2) /* Receive Timestamp. */
+#define TSINTR_TT0       (1 << 3) /* Target Time 0 Trigger. */
+#define TSINTR_TT1       (1 << 4) /* Target Time 1 Trigger. */
+#define TSINTR_AUTT0     (1 << 5) /* Auxiliary Timestamp 0 Taken. */
+#define TSINTR_AUTT1     (1 << 6) /* Auxiliary Timestamp 1 Taken. */
+#define TSINTR_TADJ      (1 << 7) /* Time Adjust Done. */
+
+#define TSYNC_INTERRUPTS TSINTR_TXTS
+#define E1000_TSICR_TXTS TSINTR_TXTS
+
+/* TSAUXC Configuration Bits */
+#define TSAUXC_EN_TT0    (1 << 0)  /* Enable target time 0. */
+#define TSAUXC_EN_TT1    (1 << 1)  /* Enable target time 1. */
+#define TSAUXC_EN_CLK0   (1 << 2)  /* Enable Configurable Frequency Clock 0. */
+#define TSAUXC_SAMP_AUT0 (1 << 3)  /* Latch SYSTIML/H into AUXSTMPL/0. */
+#define TSAUXC_ST0       (1 << 4)  /* Start Clock 0 Toggle on Target Time 0. */
+#define TSAUXC_EN_CLK1   (1 << 5)  /* Enable Configurable Frequency Clock 1. */
+#define TSAUXC_SAMP_AUT1 (1 << 6)  /* Latch SYSTIML/H into AUXSTMPL/1. */
+#define TSAUXC_ST1       (1 << 7)  /* Start Clock 1 Toggle on Target Time 1. */
+#define TSAUXC_EN_TS0    (1 << 8)  /* Enable hardware timestamp 0. */
+#define TSAUXC_AUTT0     (1 << 9)  /* Auxiliary Timestamp Taken. */
+#define TSAUXC_EN_TS1    (1 << 10) /* Enable hardware timestamp 0. */
+#define TSAUXC_AUTT1     (1 << 11) /* Auxiliary Timestamp Taken. */
+#define TSAUXC_PLSG      (1 << 17) /* Generate a pulse. */
+#define TSAUXC_DISABLE   (1 << 31) /* Disable SYSTIM Count Operation. */
+
+/* SDP Configuration Bits */
+#define AUX0_SEL_SDP0    (0 << 0)  /* Assign SDP0 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP1    (1 << 0)  /* Assign SDP1 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP2    (2 << 0)  /* Assign SDP2 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP3    (3 << 0)  /* Assign SDP3 to auxiliary time stamp 0. */
+#define AUX0_TS_SDP_EN   (1 << 2)  /* Enable auxiliary time stamp trigger 0. */
+#define AUX1_SEL_SDP0    (0 << 3)  /* Assign SDP0 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP1    (1 << 3)  /* Assign SDP1 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP2    (2 << 3)  /* Assign SDP2 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP3    (3 << 3)  /* Assign SDP3 to auxiliary time stamp 1. */
+#define AUX1_TS_SDP_EN   (1 << 5)  /* Enable auxiliary time stamp trigger 1. */
+#define TS_SDP0_SEL_TT0  (0 << 6)  /* Target time 0 is output on SDP0. */
+#define TS_SDP0_SEL_TT1  (1 << 6)  /* Target time 1 is output on SDP0. */
+#define TS_SDP0_SEL_FC0  (2 << 6)  /* Freq clock  0 is output on SDP0. */
+#define TS_SDP0_SEL_FC1  (3 << 6)  /* Freq clock  1 is output on SDP0. */
+#define TS_SDP0_EN       (1 << 8)  /* SDP0 is assigned to Tsync. */
+#define TS_SDP1_SEL_TT0  (0 << 9)  /* Target time 0 is output on SDP1. */
+#define TS_SDP1_SEL_TT1  (1 << 9)  /* Target time 1 is output on SDP1. */
+#define TS_SDP1_SEL_FC0  (2 << 9)  /* Freq clock  0 is output on SDP1. */
+#define TS_SDP1_SEL_FC1  (3 << 9)  /* Freq clock  1 is output on SDP1. */
+#define TS_SDP1_EN       (1 << 11) /* SDP1 is assigned to Tsync. */
+#define TS_SDP2_SEL_TT0  (0 << 12) /* Target time 0 is output on SDP2. */
+#define TS_SDP2_SEL_TT1  (1 << 12) /* Target time 1 is output on SDP2. */
+#define TS_SDP2_SEL_FC0  (2 << 12) /* Freq clock  0 is output on SDP2. */
+#define TS_SDP2_SEL_FC1  (3 << 12) /* Freq clock  1 is output on SDP2. */
+#define TS_SDP2_EN       (1 << 14) /* SDP2 is assigned to Tsync. */
+#define TS_SDP3_SEL_TT0  (0 << 15) /* Target time 0 is output on SDP3. */
+#define TS_SDP3_SEL_TT1  (1 << 15) /* Target time 1 is output on SDP3. */
+#define TS_SDP3_SEL_FC0  (2 << 15) /* Freq clock  0 is output on SDP3. */
+#define TS_SDP3_SEL_FC1  (3 << 15) /* Freq clock  1 is output on SDP3. */
+#define TS_SDP3_EN       (1 << 17) /* SDP3 is assigned to Tsync. */
 
 #define E1000_MDICNFG_EXT_MDIO    0x80000000      /* MDI ext/int destination */
 #define E1000_MDICNFG_COM_MDIO    0x40000000      /* MDI shared w/ lan 0 */
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 82632c6..be841d1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -41,6 +41,7 @@
 #define E1000_FCT      0x00030  /* Flow Control Type - RW */
 #define E1000_CONNSW   0x00034  /* Copper/Fiber switch control - RW */
 #define E1000_VET      0x00038  /* VLAN Ether Type - RW */
+#define E1000_TSSDP    0x0003C  /* Time Sync SDP Configuration Register - RW */
 #define E1000_ICR      0x000C0  /* Interrupt Cause Read - R/clr */
 #define E1000_ITR      0x000C4  /* Interrupt Throttling Rate - RW */
 #define E1000_ICS      0x000C8  /* Interrupt Cause Set - WO */
@@ -102,6 +103,14 @@
 #define E1000_SYSTIMH    0x0B604 /* System time register High - RO */
 #define E1000_TIMINCA    0x0B608 /* Increment attributes register - RW */
 #define E1000_TSAUXC     0x0B640 /* Timesync Auxiliary Control register */
+#define E1000_TRGTTIML0  0x0B644 /* Target Time Register 0 Low  - RW */
+#define E1000_TRGTTIMH0  0x0B648 /* Target Time Register 0 High - RW */
+#define E1000_TRGTTIML1  0x0B64C /* Target Time Register 1 Low  - RW */
+#define E1000_TRGTTIMH1  0x0B650 /* Target Time Register 1 High - RW */
+#define E1000_AUXSTMPL0  0x0B65C /* Auxiliary Time Stamp 0 Register Low  - RO */
+#define E1000_AUXSTMPH0  0x0B660 /* Auxiliary Time Stamp 0 Register High - RO */
+#define E1000_AUXSTMPL1  0x0B664 /* Auxiliary Time Stamp 1 Register Low  - RO */
+#define E1000_AUXSTMPH1  0x0B668 /* Auxiliary Time Stamp 1 Register High - RO */
 #define E1000_SYSTIMR    0x0B6F8 /* System time register Residue */
 #define E1000_TSICR      0x0B66C /* Interrupt Cause Register */
 #define E1000_TSIM       0x0B674 /* Interrupt Mask Register */
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 7e8c477..ebc2f72 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -798,7 +798,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 
 	/* Initialize the time sync interrupts for devices that support it. */
 	if (hw->mac.type >= e1000_82580) {
-		wr32(E1000_TSIM, E1000_TSIM_TXTS);
+		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 	}
 
@@ -876,7 +876,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i211:
 		/* Enable the timer functions and interrupts. */
 		wr32(E1000_TSAUXC, 0x0);
-		wr32(E1000_TSIM, E1000_TSIM_TXTS);
+		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
 	default:
-- 
1.7.10.4


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
